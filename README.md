# Azure CycleCloud テンプレート for MSC scFLOW

[Azure CycleCloud](https://docs.microsoft.com/en-us/azure/cyclecloud/) はMicrosoft Azure上で簡単にCAE/HPC/Deep Learning用のクラスタ環境を構築で>きるソリューションです。

Azure CyceCloudのインストールに関しては、[こちら](https://docs.microsoft.com/en-us/azure/cyclecloud/quickstart-install-cyclecloud) のドキュメン>トを参照してください。

## テンプレート詳細
scFLOW用のテンプレートになっています。
以下の構成、特徴を持っています。

1. Slurmジョブスケジューラをschedulerノードにインストール
1. H16r, H16r_Promo, HC44rs, HB60rs, HB120rs_v2などソルバー利用を想定した設定
    - OpenLogic CentOS 7.6 HPC を利用
1. NFS設定されており、ホームディレクトリが永続ディスク設定。Executeノード（計算ノード）からNFSをマウント
1. MasterノードのIPアドレスを固定設定
    - 一旦停止後、再度起動した場合にアクセスする先のIPアドレスが変更されない
1. 対応ソルバ
    - scFLOW 2020

## テンプレートインストール方法

**前提条件:** テンプレートを利用するためには、Azure CycleCloud CLIのインストールと設定が必要です。詳しくは、 [こちら](https://docs.microsoft.com/en-us/azure/cyclecloud/install-cyclecloud-cli) の文書からインストールと展開されたAzure CycleCloudサーバのFQDNの設定が必要です。

1. テンプレート本体をダウンロード
1. 展開、ディレクトリ移動
1. cyclecloudコマンドラインからテンプレートインストール
   - tar zxvf cyclecloud-scFLOW<version>.tar.gz
   - /blobディレクトリにGAMESSやNAMDなどソースコード、およびバイナリを設定します。
         - cd blob
         - wget https://hirostpublicshare.blob.core.windows.net/solvers/blobs.tar.gz
   - cd cyclecloud-iochembd<version>
   - cyclecloud project upload cyclecloud-storage (Lockerの指定)
   - cyclecloud import_template -f templates/slurm-scflow.txt
1. 削除したい場合、 cyclecloud delete_template scFLOW コマンドで削除可能

## 利用方法

## 制限事項
1. GPUが利用できるリージョンでの利用を想定しています。東日本リージョンなどが対象です。西日本は対応していません。
1. Azure CycleCloudの対応バージョンは 8.1.x以降になります。

***
Copyright Hiroshi Tanaka, hirtanak@gmail.com, @hirtanak All rights reserved.
Use of this source code is governed by MIT license that can be found in the LICENSE file.
