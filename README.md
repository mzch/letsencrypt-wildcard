# Get wildcard certificates from Let's Encrypt

これは、[Value-Domain](https://www.value-domain/) のネームサーバーを使用しているドメインのワイルドカード TLS 証明書を Certbot を使って Let's Encrypt から取得するためのスクリプト集です。


#### 必要なコマンド

|コマンド|備考|
| ---- | ---- |
| `Bash` | https://www.gnu.org/software/bash/ |
| `Gawk` | https://www.gnu.org/software/gawk/ (BSD awk でも動作するかどうかは検証していません) |
| `jq` | https://jqlang.org/ |
| `Curl` | https://curl.se/ |
| `Certbot` | https://certbot.eff.org/ |

#### 事前設定

1. [Value-Domain](https://www.value-domain.com/) にログインします。
1. マイページへ移動し、API 設定を選択します。
1. 許可 IP を設定します。
1. API トークンを発行します。
1. 取得した API トークンをホームディレクトリの `.vd-token` と名前をつけたファイルに保存します。
1. `dns-hook-vd.sh`、`clean-hook-vd.sh`, `wild-vd.sh` の三つのスクリプトをパスが通ったディレクトリ、もしくは、`/etc/letsencrypt` ディレクトリにコピーします。
1. 上記三つのスクリプトに `chmod +x *.sh` などとして実行券を与えます。
1. Let's Encrypt 登録用のメールアドレスを環境変数 `LE_EMAIL` に設定しておきます（任意）。

#### 使用方法

```bash
wild-vd.sh example.com [メールアドレス]
```

`example.com` は、ワイルドカード証明書が必要なドメインを指定します。第２引数のメールアドレスは、Let's Encrypt 登録用のアドレスを指定します。以前は期限切れ間近の証明書があるとアラートが送られてきたりしていたのですが、今現在はそのサービスを取りやめてしまっているので、適当な捨てアカでも構いません。ただし、適当でよいからといって実在しないアドレスを指定することはお勧めしません。万が一ですが、Let's Encrypt のシステムに重大な問題が発生した際に通知が来なくて詰んでしまう可能性があります。

環境変数 `LE_EMAIL` にメールアドレスが指定されている場合はこの引数を省略することができます。

### 環境変数

|環境変数名|設定内容|
| :------------ | :----- |
|`LE_EMAIL`|Let's Encrypt 登録用のアドレス。|
|`VD_NAMESERVER`| Value-Domain のネームサーバー種別を指定します。`ns1-5.value-domain.com` 使用時は `valuedomain1` を `ns11-13.value-domain.com` 使用時は `valuedomain11` を指定してください。それ以外の値の場合、エラーになります。デフォルトは、`valuedomain1` です。|


#### ライセンス

MIT License.