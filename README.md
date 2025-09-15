# CC:Tweaked Fennel Project

MinecraftのCC:Tweaked mod向けFennelプロジェクトテンプレート

## セットアップ

```bash
npm install
```

## ビルド

Fennelコードを単一のLuaファイルにコンパイル:

```bash
npm run build
# または
make build
```

出力: `dist/main.lua`

## 開発

```bash
npm run dev
# または
make watch
```

## プロジェクト構成

```
├── src/
│   └── main.fnl          # メインのFennelソースファイル
├── dist/
│   └── main.lua          # コンパイル済みLuaファイル
├── package.json          # NPM設定
└── Makefile             # ビルド設定
```

## CC:Tweakedでの使用

1. `dist/main.lua`をCC:TweakedのコンピュータまたはTurtleにコピー
2. `main`コマンドで実行

## 機能例

- タートルの基本移動
- ブロック採掘・設置
- 燃料レベル確認
- 周辺機器検出