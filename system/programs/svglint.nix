{
  pkgs,
  lib,
  ...
}: let
  version = "4.2.0";

  svglint = pkgs.buildNpmPackage {
    pname = "svglint";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "simple-icons";
      repo = "svglint";
      rev = "v${version}";
      hash = "sha256-FhJ11L+jKAw0wvxtOA2b8uerbQqaFoyUVvxkQhGXzKo=";
    };

    npmDepsHash = "sha256-ScrPMW/R+ueTjHu5zBTdI+aHJAB+7K+zyS9PVSQ3woE=";
    npmBuildScript = "prepublishOnly";

    meta = with lib; {
      description = "Linter for SVG files";
      homepage = "https://github.com/simple-icons/svglint";
      license = licenses.mit;
      #maintainers = with maintainers; [ winter ];
    };
  };
in {
  environment.systemPackages = [svglint];
}
