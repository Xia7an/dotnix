{pkgs, inputs, ...} : {
    environment.systemPackages = with pkgs;[
        github-copilot-cli
    ];
}