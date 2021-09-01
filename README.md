# tex-environment
Dockerのコンテナ内でtexをbuild

# 手順
※ dockerはインストールされている前提です．
- 下記コマンドで `Dockerfile`をbuild
    注意： 後述の `setting.json` で指定するものと同じimage名を指定してbuild
    ```
    $ docker built -t tex
    ```

- VScodeをダウンロード

- VScodeに下記の拡張機能を追加
    - TeX Workshop
    - Latex language support

- VScodeの左上の「ファイル」→「ユーザー設定」→「設定[Ctrl+,]」→右上あたりのアイコン「設定（JSON）を開く」をクリックして `setting.json`下記のように追記
    ```
    //ここから下を追記（常に，latex-workshop.tools,latex-workshop.latex.recipesが記述されている場合は上書きする． ）
	"latex-workshop.latex.recipes": [
	        {
	            "name": "compile",
	            "tools":
	            [
	                "platex_dvipdfmx"
	            ]
	        },
	        {
	            "name": "bib_compile",
	            "tools":
	            [
	                "platex_pbibtex_dvipdfmx"
	            ]
	        }
	        ],
	        "latex-workshop.latex.tools": [
	        {
	            "name": "platex_dvipdfmx",
	            // 下記は、コンパイルしたいtexファイルを「hoge.tex」とした場合
	            // $ docker run --rm -v $(pwd):/workdir tex sh -c "platex hoge.tex && platex hoge.tex && dvipdfmx hoge"
	            // と同じ
	            "command": "docker",
	            "args":
	            [
	                "run", // docker run
	                "--rm", //  docker run option, --rm: コンテナから抜けたら削除
	                "-v", // docker run option, -v: 指定したディレクトリをコンテナ内のディレクトリとマウント
	                "%DIR%:/workdir", //ローカル側のディレクトリ:コンテナ内のディレクトリ
	                "tex", //image名※ docker buildの時に指定したimage名を記述．今回の場合docker buildの時に右コマンドのように指定されていれば良い $docker built -t tex
	                "sh", // 「$ sh コマンド名」の形でコマンドを打つ（ここからコンテナ内で実行されるコマンド）
	                "-c", // 複数のコマンドを入力可能にするオプション（&&で複数のコマンドを実行可）
	                "platex %DOCFILE% && platex %DOCFILE% && dvipdfmx %DOCFILE%" //platex → platex → dvipdfmx
	            ]
	        },
	        {
	            "name": "platex_pbibtex_dvipdfmx",
	            // 下記は、コンパイルしたいtexファイルを「hoge.tex」とした場合
	            // $ docker run --rm -v $(pwd):/workdir tex sh -c "platex hoge.tex && pbibtex hoge && platex hoge.tex && platex hoge.tex  && dvipdfmx hoge"
	            // と同じ
	            "command": "docker",
	            "args":
	            [
	                "run", // docker run
	                "--rm", // docker run option, --rm: コンテナから抜けたら削除
	                "-v", // docker run option, -v: 指定したディレクトリをコンテナ内のディレクトリとマウント
	                "%DIR%:/workdir", //ローカル側のディレクトリ:コンテナ内のディレクトリ
	                "tex", // image名 ※ docker buildの時に指定したimage名を記述．今回の場合docker buildの時に右コマンドのように指定されていれば良い $docker built -t tex
	                "sh", // 「$ sh コマンド名」の形でコマンドを打つ（ここからコンテナ内で実行されるコマンド）
	                "-c", // 複数のコマンドを入力可能にするオプション（&&で複数のコマンドを実行可）
	                "platex %DOCFILE% && pbibtex %DOCFILE% && platex %DOCFILE% && platex %DOCFILE% && dvipdfmx %DOCFILE%" //platex → pbibtex → platex platex → dvipdfmx（bibfileを適応させたコンパイル）
	            ]
	        }
	    ],
	    "latex-workshop.latex.autoBuild.run": "onFileChange",
	    "latex-workshop.view.pdf.viewer": "browser",
		 //ここまで追記（ここから下にも他の拡張機能などの設定がある場合は，特に変更しなくてもOK）
	   //その他設定．
    ```
    デフォルトだとtexファイルを保存した時に `setting.json`の `latex-workshop.latex.recipes`の一番上のレシピが実行されるので「platex」→「platex」→「dvipdfmx」の順番で
    コンパイルされる．

    言い換えると，2番目のbibtexを適応したレシピは保存しただけでは実行されないので下記の設定を行う．  
    1.  「ファイル」→「ユーザー設定」→「キーボードショートカット[Ctrl+K Ctrl+S]」  
    2. 「LaTeX Workshop:Build with recipe」で検索して任意のショートカットを設定（以降の説明では，ショートカットキーに`alt`+`b`を設定したと仮定して進める）

    上記の設定が完了した状態で，bibファイルを適応したいときはtexファイルを保存する代わりに`alt` +`b`→ `bib_compile`を選択．  
    生成されるpdfにbibファイルが適応（参考文献が追加）されていればOK
    </br>
## 追加パッケージ（apt-get installではインストールされないパッケージ）
-  日本語のソースコード記述のパッケージをセットアップ
    - https://ja.osdn.net/projects/mytexpert/downloads/26068/jlisting.sty.bz2/
- アルゴリズム記述のパッケージをセットアップ
    - https://www.ctan.org/pkg/algorithm2e
