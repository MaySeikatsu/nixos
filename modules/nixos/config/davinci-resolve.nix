# DaVinci Resolve with its UI and compute on the NVIDIA GPU.
#
# The `davinci-resolve` binary itself is wrapped, so the .desktop entry
# (which runs it from PATH) and terminals behave the same:
# - Qt is forced to X11. Resolve bundles its own Qt 5 with only the xcb
#   platform plugin; the niri and mango sessions export
#   QT_QPA_PLATFORM=wayland, which makes it abort before any window shows.
#   The session's Qt theme/plugin variables point at the system Qt and are
#   dropped for the same reason (mixing Qt builds crashes or misrenders).
# - On a PRIME-offload laptop, the NVIDIA offload variables: Resolve needs
#   its OpenGL context on the same GPU it runs CUDA on, otherwise the UI
#   lands on the iGPU and Resolve can't use the NVIDIA card.
# On the PC Resolve then finds the card on its own (CUDA + NVDEC on the GTX
# 1060, checked in ResolveDebug.txt).
#
# Still CPU-bound in the free version on Linux, by Blackmagic's design: H.264
# / H.265 decoding and AAC audio (Studio only). Hence resolve-transcode and
# the ingest folder below, which convert such clips to DNxHR + PCM.
{
  config,
  lib,
  pkgs,
  ...
}: let
  nvidia = config.hardware.nvidia;
  # the laptop's no-nvidia specialisation keeps offload enabled but
  # blacklists the driver; forcing the NVIDIA GLX vendor there would leave
  # Resolve with no OpenGL at all
  offload =
    nvidia.prime.offload.enable
    && !(lib.elem "nvidia" config.boot.blacklistedKernelModules);

  resolve = pkgs.symlinkJoin {
    name = "davinci-resolve-wrapped";
    paths = [pkgs.davinci-resolve];
    nativeBuildInputs = [pkgs.makeWrapper];
    # only the main entry point; the other bins (BRAW player, panels setup,
    # ...) re-exec `$(dirname $0)/davinci-resolve`, i.e. this one
    postBuild = ''
      wrapProgram $out/bin/davinci-resolve \
        --set QT_QPA_PLATFORM xcb \
        --unset QT_QPA_PLATFORMTHEME \
        --unset QT_STYLE_OVERRIDE \
        --unset QT_PLUGIN_PATH \
        ${lib.optionalString offload ''
        --set __NV_PRIME_RENDER_OFFLOAD 1 \
        --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
        --set __GLX_VENDOR_LIBRARY_NAME nvidia \
        --set __VK_LAYER_NV_optimus NVIDIA_only \
      ''}
    '';
  };

  # resolve-transcode <file|dir>... [-o outdir]
  # Converts only what the free version can't decode (H.264/H.265 video,
  # AAC/other compressed audio); ProRes, DNxHR, BRAW, R3D etc. are skipped.
  # 10-bit sources (e.g. N-Log/HLG H.265 from the Nikon ZR) become DNxHR HQX
  # 10-bit so no grading latitude is lost; 8-bit becomes DNxHR HQ. Colour
  # metadata (primaries/transfer/matrix, i.e. HLG/PQ tags) is carried over.
  # Decoding runs on NVDEC when possible. Existing outputs are skipped.
  transcode = pkgs.writeShellApplication {
    name = "resolve-transcode";
    runtimeInputs = [pkgs.ffmpeg pkgs.findutils];
    text = ''
      outdir=""
      inputs=()
      while [ $# -gt 0 ]; do
        case "$1" in
          -o) outdir=$2; shift 2 ;;
          -h|--help)
            echo "usage: resolve-transcode <video|dir>... [-o outdir]"
            echo "  H.264/H.265 -> DNxHR (HQX for 10-bit) + PCM .mov, default next to the source"
            exit 0 ;;
          *) inputs+=("$1"); shift ;;
        esac
      done
      [ ''${#inputs[@]} -gt 0 ] || { echo "usage: resolve-transcode <video|dir>... [-o outdir]" >&2; exit 1; }

      probe() { ffprobe -v error -select_streams "$1" -show_entries "stream=$2" -of csv=p=0 "$3" | head -n1; }

      convert() {
        local f=$1 vcodec pixfmt profile outfmt dest
        vcodec=$(probe v:0 codec_name "$f")
        case "$vcodec" in
          h264|hevc) ;;
          "") return 0 ;; # not a video
          *) echo "skip (already editable: $vcodec): $f"; return 0 ;;
        esac
        pixfmt=$(probe v:0 pix_fmt "$f")
        if [[ "$pixfmt" == *10* || "$pixfmt" == *12* ]]; then
          profile=dnxhr_hqx outfmt=yuv422p10le
        else
          profile=dnxhr_hq outfmt=yuv422p
        fi
        dest=''${outdir:-$(dirname "$f")}/$(basename "''${f%.*}").dnxhr.mov
        [ -e "$dest" ] && { echo "exists: $dest"; return 0; }
        mkdir -p "$(dirname "$dest")"
        echo "transcoding ($vcodec $pixfmt -> $profile): $f"
        # write to a temp name first so a half-written file is never picked up
        ffmpeg -nostdin -hide_banner -loglevel warning -stats -hwaccel auto -i "$f" \
          -map 0:v:0 -map '0:a?' -map_metadata 0 \
          -c:v dnxhd -profile:v "$profile" -pix_fmt "$outfmt" \
          -c:a pcm_s24le \
          -f mov "$dest.part" && mv "$dest.part" "$dest"
      }

      for i in "''${inputs[@]}"; do
        if [ -d "$i" ]; then
          while IFS= read -r -d "" f; do convert "$f"; done \
            < <(find "$i" -path '*/transcoded' -prune -o -type f -iregex '.*\.\(mp4\|mov\|mkv\|m4v\|mts\|avi\)' -print0)
        else
          convert "$i"
        fi
      done
    '';
  };

  # Drop clips into ~/Videos/Resolve-Ingest; editable copies appear in its
  # transcoded/ subfolder and can be imported into Resolve from there.
  ingest = pkgs.writeShellApplication {
    name = "resolve-ingest";
    runtimeInputs = [transcode pkgs.inotify-tools];
    text = ''
      dir=''${1:-$HOME/Videos/Resolve-Ingest}
      mkdir -p "$dir/transcoded"
      # catch up on anything that arrived while the watcher wasn't running
      resolve-transcode "$dir" -o "$dir/transcoded" || true
      inotifywait -m -q -e close_write -e moved_to --exclude '/transcoded/' --format '%w%f' "$dir" |
        while IFS= read -r f; do
          resolve-transcode "$f" -o "$dir/transcoded" || echo "failed: $f"
        done
    '';
  };
  # resolve-deliver <master>... [-o outdir] [--sdr|--hdr] [--h265]
  # The free Resolve can't encode H.264/H.265 on Linux. Render a master
  # instead (Deliver: QuickTime, DNxHR HQX 10-bit or ProRes 422 HQ, PCM) and
  # turn it into an upload file here, encoded on the GPU (NVENC):
  # - SDR master (Rec.709)            -> H.264 High, AAC  (.mp4)
  # - HDR master (HLG or PQ / BT.2020) -> H.265 Main10, AAC, HDR tags kept
  # HDR is detected from the master's colour tags, so in Resolve set the
  # output colour space/gamma tags (Deliver > Advanced) to Rec.2020 +
  # Rec.2100 HLG or ST2084. Falls back to the CPU encoders (libx264/libx265)
  # when NVENC isn't available (busy VRAM, no-nvidia boot entry).
  deliver = pkgs.writeShellApplication {
    name = "resolve-deliver";
    runtimeInputs = [pkgs.ffmpeg pkgs.findutils];
    text = ''
      outdir=""
      force=""
      h265=""
      inputs=()
      while [ $# -gt 0 ]; do
        case "$1" in
          -o) outdir=$2; shift 2 ;;
          --sdr) force=sdr; shift ;;
          --hdr) force=hdr; shift ;;
          --h265) h265=1; shift ;;
          -h|--help)
            echo "usage: resolve-deliver <master|dir>... [-o outdir] [--sdr|--hdr] [--h265]"
            echo "  Resolve master (DNxHR/ProRes) -> upload-ready .mp4 (GPU encode)"
            echo "  HLG/PQ masters become 10-bit HDR H.265 automatically"
            exit 0 ;;
          *) inputs+=("$1"); shift ;;
        esac
      done
      [ ''${#inputs[@]} -gt 0 ] || { echo "usage: resolve-deliver <master|dir>... [-o outdir] [--sdr|--hdr] [--h265]" >&2; exit 1; }

      probe() { ffprobe -v error -select_streams v:0 -show_entries "stream=$1" -of csv=p=0 "$2" | head -n1; }

      encode() { # <in> <out> <mode> <gpu|cpu>
        local in=$1 out=$2 mode=$3 dev=$4 v=()
        case "$mode/$dev" in
          hdr/gpu) v=(-c:v hevc_nvenc -preset p6 -tune hq -rc vbr -cq 20 -profile:v main10 -pix_fmt p010le -tag:v hvc1) ;;
          hdr/cpu) v=(-c:v libx265 -preset slow -crf 18 -pix_fmt yuv420p10le -tag:v hvc1) ;;
          h265/gpu) v=(-c:v hevc_nvenc -preset p6 -tune hq -rc vbr -cq 21 -pix_fmt yuv420p -tag:v hvc1) ;;
          h265/cpu) v=(-c:v libx265 -preset slow -crf 20 -pix_fmt yuv420p -tag:v hvc1) ;;
          sdr/gpu) v=(-c:v h264_nvenc -preset p6 -tune hq -rc vbr -cq 19 -profile:v high -pix_fmt yuv420p) ;;
          sdr/cpu) v=(-c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p) ;;
        esac
        # colour tags travel with the frames (ffmpeg >= 7), keeping HLG/PQ
        ffmpeg -nostdin -hide_banner -loglevel warning -stats -y -i "$in" \
          -map 0:v:0 -map '0:a?' -map_metadata 0 \
          "''${v[@]}" -c:a aac -b:a 320k -movflags +faststart \
          "$out"
      }

      deliver_one() {
        local f=$1 trc mode dest
        trc=$(probe color_transfer "$f")
        [ -n "$trc" ] || return 0 # not a video
        if [ -n "$force" ]; then mode=$force
        else
          case "$trc" in arib-std-b67|smpte2084) mode=hdr ;; *) mode=sdr ;; esac
        fi
        [ "$mode" = sdr ] && [ -n "$h265" ] && mode=h265
        dest=''${outdir:-$(dirname "$f")}/$(basename "''${f%.*}").$mode.mp4
        [ -e "$dest" ] && { echo "exists: $dest"; return 0; }
        mkdir -p "$(dirname "$dest")"
        echo "delivering ($trc -> $mode): $f"
        if ! encode "$f" "$dest.part.mp4" "$mode" gpu; then
          echo "NVENC failed, encoding on the CPU (slower)" >&2
          encode "$f" "$dest.part.mp4" "$mode" cpu
        fi
        mv "$dest.part.mp4" "$dest"
      }

      for i in "''${inputs[@]}"; do
        if [ -d "$i" ]; then
          while IFS= read -r -d "" f; do deliver_one "$f"; done \
            < <(find "$i" -path '*/delivery' -prune -o -type f -iregex '.*\.\(mov\|mxf\|mkv\)' -print0)
        else
          deliver_one "$i"
        fi
      done
    '';
  };

  # Point Resolve's render location at ~/Videos/Resolve-Exports; finished
  # renders are converted into its delivery/ subfolder.
  exportWatch = pkgs.writeShellApplication {
    name = "resolve-export-watch";
    runtimeInputs = [deliver pkgs.inotify-tools];
    text = ''
      dir=''${1:-$HOME/Videos/Resolve-Exports}
      mkdir -p "$dir/delivery"
      resolve-deliver "$dir" -o "$dir/delivery" || true
      inotifywait -m -q -e close_write -e moved_to --exclude '/delivery/' --format '%w%f' "$dir" |
        while IFS= read -r f; do
          resolve-deliver "$f" -o "$dir/delivery" || echo "failed: $f"
        done
    '';
  };
in {
  # toggle: my.videoEditing.enable (modules/nixos/profiles.nix)
  config = lib.mkIf config.my.videoEditing.enable {
    environment.systemPackages = [
      resolve
      transcode
      deliver
    ];

    systemd.user.services.resolve-ingest = {
      description = "Transcode H.264/H.265 clips dropped into ~/Videos/Resolve-Ingest for DaVinci Resolve";
      wantedBy = ["default.target"];
      serviceConfig = {
        ExecStart = lib.getExe ingest;
        Nice = 10; # transcoding is CPU-heavy, keep the desktop responsive
        Restart = "on-failure";
      };
    };

    systemd.user.services.resolve-export = {
      description = "Convert DaVinci Resolve renders in ~/Videos/Resolve-Exports to upload-ready MP4s";
      wantedBy = ["default.target"];
      serviceConfig = {
        ExecStart = lib.getExe exportWatch;
        Nice = 10;
        Restart = "on-failure";
      };
    };
  };
}
