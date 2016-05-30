{ pkgs }:

rec {

  i3lock-color = pkgs.i3lock.overrideDerivation (old: rec {
    rev = "177024ddc01d9f86fef8e9daa766166ee58aa04d";
    name = "i3lock-color-2016-02-09-${rev}";
    src = pkgs.fetchFromGitHub {
      owner = "Arcaena";
      repo = "i3lock-color";
      inherit rev;
      sha256 = "0r5rv0s2z16brqjsy8cxjiq108dxdrr0f8iizy3324hz99jrcslc";
    };
  });

 # mysql-workbench = pkgs.mysqlWorkbench.overrideDerivation (old: rec{
 #   version = "6.0.4";
 #   pname = "mysql-workbench";
 #   name = "${pname}-${version}";
 #   src = pkgs.fetchurl {
 #     url = "http://mirror.cogentco.com/pub/mysql/MySQLGUITools/mysql-workbench-gpl-6.0.4-src.tar.gz";
 #     sha256 = "0gkk8ldhspy2a5yvx0l40ih9bm9gsx2qwf4z8pk961nlcpr2550i";
 #   };
 #   postConfigure = ''
 #   cmake $out -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_BUILD_TYPE=Release
 #   '';
 #   nativeBuildInputs = with pkgs; [ boost cmake file glib glibc 
 #                                    libgnome_keyring gtk gtkmm intltool
 #                                    libctemplate gnome.libglade gnome.libgnome 
 #                                    libiodbc libsigcxx libuuid libxml2 libzip 
 #                                    lua makeWrapper mesa libmysql
 #                                    python27Packages.paramiko pcre  
 #                                    python27Packages.pexpect pkgconfig 
 #                                    python27Packages.pycrypto python27Packages.python sqlite ];
 # });

  i3lock-fancy = pkgs.stdenv.mkDerivation rec {
    rev = "b7005a0bfb3e2bef119e41c57ae2765d49aadea7";
    name = "i3lock-fancy-2016-01-13-${rev}";
    src = pkgs.fetchFromGitHub {
      owner = "meskarune";
      repo = "i3lock-fancy";
      inherit rev;
      sha256 = "eb5b1f2eb7c79d52604d1daaad65ed80bcb0601c8944d7004b3c4f1512414a3d";
    };
    buildInputs = with pkgs; [ coreutils scrot imagemagick gnused i3lock-color ];
    patchPhase = ''
      sed -i -e "s|mktemp|${pkgs.coreutils}/bin/mktemp|" lock
      sed -i -e "s|\`pwd\`|$out/share/i3lock-fancy|" lock
      sed -i -e "s|dirname|${pkgs.coreutils}/bin/dirname|" lock
      sed -i -e "s|rm |${pkgs.coreutils}/bin/rm |" lock
      sed -i -e "s|scrot |${pkgs.scrot}/bin/scrot |" lock
      sed -i -e "s|convert |${pkgs.imagemagick}/bin/convert |" lock
      sed -i -e "s|sed |${pkgs.gnused}/bin/sed |" lock
      sed -i -e "s|i3lock |${i3lock-color}/bin/i3lock-color |" lock
    '';
    installPhase = ''
      mkdir -p $out/bin $out/share/i3lock-fancy
      cp lock $out/bin/i3lock-fancy
      cp lock*.png $out/share/i3lock-fancy
    '';
  };

}
