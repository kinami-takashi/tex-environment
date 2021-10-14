FROM ubuntu:18.04
RUN apt-get update -y && apt-get upgrade -y &&\
apt-get install -y \
tzdata
RUN apt-get install -y \
sudo \
vim \
texlive-lang-japanese \
texlive-latex-extra \
texlive-bibtex-extra
RUN apt-get install -y \
zip \
wget \
tar \
bzip2

# 「/usr/share/texlive/texmf-dist/tex/latex」内に外部パッケージをDL
WORKDIR  /usr/share/texlive/texmf-dist/tex/latex

# 日本語のソースコード記述のパッケージをセットアップ
# 「https://ja.osdn.net/projects/mytexpert/downloads/26068/jlisting.sty.bz2/」よりダウンロード
# →ダウンロードしたファイルを右クリック→「ダウンロードリンクのコピー」より取得したURLをwget
RUN wget https://osdn.mirror.liquidtelecom.com/mytexpert/26068/jlisting.sty.bz2
RUN bzip2 -d jlisting.sty.bz2
RUN chmod 664 jlisting.sty

# アルゴリズム記述のパッケージをセットアップ
# 「https://www.ctan.org/pkg/algorithm2e」よりダウンロード
# →ダウンロードしたファイルを右クリック→「ダウンロードリンクのコピー」より取得したURLをwget
RUN wget https://ftp.jaist.ac.jp/pub/CTAN/macros/latex/contrib/algorithm2e.zip
RUN unzip algorithm2e.zip
RUN mv algorithm2e/tex/algorithm2e.sty .
RUN chmod 664 algorithm2e.sty

#他のパッケージを追加するときも同様に「styファイルをwgetコマンドで「/usr/share/texlive/texmf-dist/tex/latex」にDL」→「mktexlsr」で適応すればOK

# 下記コマンドで追加したパッケージを適応
RUN mktexlsr

# ---------------------------------------
# https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user
# rootでログインすると，全部のファイルがroot権限になって扱いが面倒なので，ユーザを作成
ARG DOCKER_UID=1000
ARG DOCKER_USER=docker
RUN useradd -m -s /bin/bash --uid ${DOCKER_UID} --groups sudo ${DOCKER_USER} \
    && echo $DOCKER_USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$DOCKER_USER \
    && chmod 0440 /etc/sudoers.d/$DOCKER_USER
# 作成したユーザーに切り替える
USER ${DOCKER_USER}
# -----------------------------------------

# pbibtexの時に、現在地点のファイルを参照するので、作業ディレクトリをマウントするディレクトリに変更しておく
WORKDIR /workdir