
********************************************************************
  すべての列を出力する
********************************************************************

SELECT *
  FROM Shohin;

 shohin_id |   shohin_mei   | shohin_bunrui | hanbai_tanka | shiire_tanka |  torokubi
-----------+----------------+---------------+--------------+--------------+------------
 0001      | Tシャツ        | 衣服          |         1000 |          500 | 2009-09-20
 0002      | 穴あけパンチ   | 事務用品      |          500 |          320 | 2009-09-11
 0003      | カッターシャツ | 衣服          |         4000 |         2800 |
 0004      | 包丁           | キッチン用品  |         3000 |         2800 | 2009-09-20
 0005      | 圧力鍋         | キッチン用品  |         6800 |         5000 | 2009-01-15
 0006      | フォーク       | キッチン用品  |          500 |              | 2009-09-20
 0007      | おろしがね     | キッチン用品  |          880 |          790 | 2008-04-28
 0008      | ボールペン     | 事務用品      |          100 |              | 2009-11-11
(8 行)

********************************************************************
  集約関数
********************************************************************

COUNT　//レコード数（行数）を数える
SUM
AVG
MAX
MIN

NULLはカウントされないので計6行

SELECT COUNT(shiire_tanka)
    FROM Shohin;

 count
-------
     6
(1 行)

COUNT(*)はNULLを含む行数
COUNT(列名）はNULLを除外した行数

********************************************************************
  重複値を除外して集約関数を使う（DISTINCTキーワード）
********************************************************************

SELECT COUNT(DISTINCT shohin_bunrui) AS dmm
    FROM Shohin;

 dmm
-----
   3
(1 行)

********************************************************************
  GROUP BY句（～ごと、～別などの重複している値を集約して、重複をなくす）
********************************************************************

SELECT shohin_bunrui, COUNT(*)
    FROM Shohin
  GROUP BY shohin_bunrui; ※GROUP BY句に指定する列のことを「集約キー」や「グループ化列」と呼ぶ

 shohin_bunrui | count
---------------+-------
 衣服          |     2
 事務用品      |     2
 キッチン用品  |     4
(3 行)

GROUP BY句の記述順序は・・・
  SELECT
  FROM
  WHERE
  GROUP BY

********************************************************************
  WHERE句を使った場合のGROUP BYの挙動
********************************************************************

まず、WHERE句で商品分類が衣類のみの２行に絞りこまれる

SELECT shiire_tanka, COUNT(*)
    FROM Shohin
  WHERE shohin_bunrui = '衣服'
  GROUP BY shiire_tanka;

 shiire_tanka | count
--------------+-------
          500 |     1
         2800 |     1
(2 行)

GROUP BY句とWHERE句を併用したときのSELECT文の実行順序
  FROM
  WHERE
  GROUP BY
  SELECT

********************************************************************
  集約関数とGROUP BY句のよくある間違い
********************************************************************

１、集約キー以外の列名をSELECT句に書いてしまってはいけない

SELECT shohin_mei, shiire_tanka, COUNT(*)
    FROM shohin
  GROUP BY shiire_tanka;

shohin_meiカラムをGROUP BY句に入れなさいー！
shiire_tankaでダブっているのは2800円
この2800円に紐づく商品名は「カッターシャツ」と「包丁」の2つだが、
どちらを表示したら良いか、マシンは判断できない！

ERROR:  column "shohin.shohin_mei" must appear in the GROUP BY clause or be used in an aggregate function
行 1: SELECT shohin_mei, shiire_tanka, COUNT(*)

２、GROUP BY句に別の別名を書いてしまってはいけない（ただし、PostgreSQLの場合は動くが非公式、他のRDBMSでは動かない）

SELECT shohin_bunrui AS sb, COUNT(*)
    FROM shohin
  GROUP BY sb;　※GROUP BY句のほうがSELECT句より前に実行されるので、別名はまだ知らないのでエラー

      sb      | count
--------------+-------
 衣服         |     2
 事務用品     |     2
 キッチン用品 |     4
(3 行)

３、WHERE句に集約関数を書いてしまってはいけない

SELECT shohin_bunrui, COUNT(*)
    FROM Shohin
  WHERE COUNT(*) = 2
  GROUP BY shohin_bunrui;

WHERE句では集約を使用できません
ERROR:  aggregate functions are not allowed in WHERE
行 3:   WHERE COUNT(*) = 2

COUNTなどの集約関数を書けるのは、
  SELECT
  HAVING
  ORDER BY
  のみ

********************************************************************
  １、HAVING句（グループ、集合に対する条件指定）
********************************************************************

WHERE句はあくまで「レコード（行）」に対する条件してなので注意！！
グループ化したものに条件指定をしてあげることはできない！！

HAVINGの記述順序(GROUP BY句の後ろ)
  SELECT
  FROM
  WHERE
  GROUP　BY
  HAVING


SELECT shohin_bunrui AS sb, COUNT(*)
    FROM Shohin
  GROUP BY shohin_bunrui
  HAVING COUNT(*) = 2;

キッチン用品が除外されている

    sb    | count
----------+-------
 衣服     |     2
 事務用品 |     2
(2 行)

********************************************************************
  ２、HAVING句（グループ、集合に対する条件指定）
********************************************************************

SELECT shohin_bunrui, AVG(hanbai_tanka)
    FROM Shohin
  GROUP BY shohin_bunrui;

 shohin_bunrui |          avg
---------------+-----------------------
 衣服          | 2500.0000000000000000
 事務用品      |  300.0000000000000000
 キッチン用品  | 2795.0000000000000000
(3 行)

HAVING句でグループに対して条件指定をする

SELECT shohin_bunrui, AVG(hanbai_tanka)
    FROM Shohin
  GROUP BY shohin_bunrui
HAVING AVG(hanbai_tanka) < 1000;

 shohin_bunrui |         avg
---------------+----------------------
 事務用品      | 300.0000000000000000
(1 行)

********************************************************************
  ３、HAVING句で書いてはいけない要素
********************************************************************

SELECT shohin_bunrui, COUNT(*)
    FROM Shohin
  GROUP BY shohin_bunrui
HAVING shohin_mei = 'ボールペン';

HAVING句もGROUP BY句を使ったときのSELECT句と同じように、
GROUP BY句で指定した集約キー以外は使用できない＝条件指定としてエラーとなる

ERROR:  column "shohin.shohin_mei" must appear in the GROUP BY clause or be used in an aggregate function
行 4: HAVING shohin_mei = 'ボールペン';

********************************************************************
  ４、HAVING句よりもWHERE句に書いたほうがいい要素
********************************************************************

集約キーに対する条件指定

SELECT shohin_bunrui, COUNT(*)
    FROM shohin
  GROUP BY shohin_bunrui
HAVING shohin_bunrui = '衣服';

 shohin_bunrui | count
---------------+-------
 衣服          |     2
(1 行)

このように集約キーに対する条件指定は、HAVING句でもWHERE句でも両方書くことができちゃう
では、どちらを使うとよいのか？（ソート処理という行の並び替え処理があり、マシンに負荷をかける処理）

  WHERE
  「行」に対する条件指定
  ソート処理の前に「行」を絞りこむので、ソート処理対象の行数を減らせて、パフォーマンスがよい

  HAVING
  「グループ」に対する条件指定
  ソート処理が終わってグループ化された後に実行処理されるため、パフォーマンスが悪い

********************************************************************
  ORDER BY句（ソートキー）
********************************************************************

SELECT shohin_id, shohin_mei, hanbai_tanka
    FROM Shohin;

 shohin_id |   shohin_mei   | hanbai_tanka
-----------+----------------+--------------
 0001      | Tシャツ        |         1000
 0002      | 穴あけパンチ   |          500
 0003      | カッターシャツ |         4000
 0004      | 包丁           |         3000
 0005      | 圧力鍋         |         6800
 0006      | フォーク       |          500
 0007      | おろしがね     |          880
 0008      | ボールペン     |          100
(8 行)

SELECT shohin_id, shohin_mei, hanbai_tanka
    FROM Shohin
  ORDER BY hanbai_tanka;

 shohin_id |   shohin_mei   | hanbai_tanka
-----------+----------------+--------------
 0008      | ボールペン     |          100
 0006      | フォーク       |          500
 0002      | 穴あけパンチ   |          500
 0007      | おろしがね     |          880
 0001      | Tシャツ        |         1000
 0004      | 包丁           |         3000
 0003      | カッターシャツ |         4000
 0005      | 圧力鍋         |         6800
(8 行)


句の記述順
  SELECT
  FROM
  WHERE
  GROUP BY
  HAVING
  GROUP BY　※最も最後に記述する


DESCキーワードで降順にする（販売単価の高い順）

SELECT shohin_id, shohin_mei, hanbai_tanka
    FROM Shohin
  ORDER BY hanbai_tanka DESC;　

 shohin_id |   shohin_mei   | hanbai_tanka
-----------+----------------+--------------
 0005      | 圧力鍋         |         6800
 0003      | カッターシャツ |         4000
 0004      | 包丁           |         3000
 0001      | Tシャツ        |         1000
 0007      | おろしがね     |          880
 0002      | 穴あけパンチ   |          500
 0006      | フォーク       |          500
 0008      | ボールペン     |          100
(8 行)

