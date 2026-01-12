{pkgs, ...}: {
  # services = {
  #   kubernetes = {
  #   };
  #   k3s = {
  #     enable = true;
  #     selinux = true;
  #   };
  # };

  home.packages = with pkgs; [
    kubectl
    kubernetes-helm
    minikube
    k9s
    k3s
  ];
}
