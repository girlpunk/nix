let
  more = {
    services = {
    };
  };
in
[
  #../services/dunst
  #../services/gpg-agent
  #../services/udiskie
  more
]
