
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


SELECT *
  FROM Shohin2;

 shohin_id |   shohin_mei   | shohin_bunrui | hanbai_tanka | shiire_tanka |  torokubi
-----------+----------------+---------------+--------------+--------------+------------
 0001      | Tシャツ        | 衣服          |         1000 |          500 | 2009-09-20
 0002      | 穴あけパンチ   | 事務用品      |          500 |          320 | 2009-09-11
 0003      | カッターシャツ | 衣服          |         4000 |         2800 |
 0009      | 手袋           | 衣服          |          800 |          500 |
 0010      | やかん         | キッチン用品  |         2000 |         1700 | 2009-09-20
(5 行)


********************************************************************
  UNION テーブルの足し算
********************************************************************

重複行(0001 ~ 0003)を排除して、テーブルを足し算する

SELECT shohin_id, shohin_mei
  FROM Shohin
UNION
SELECT shohin_id, shohin_mei
  FROM Shohin2
ORDER BY shohin_id;

 shohin_id |   shohin_mei
-----------+----------------
 0001      | Tシャツ
 0002      | 穴あけパンチ
 0003      | カッターシャツ
 0004      | 包丁
 0005      | 圧力鍋
 0006      | フォーク
 0007      | おろしがね
 0008      | ボールペン
 0009      | 手袋
 0010      | やかん
(10 行)

********************************************************************
  集合演算の注意事項
********************************************************************

注意１：レコードの列数を同じであること

-- 列数が不一致のためエラー
SELECT shohin_id, shohin_mei
  FROM Shohin
UNION
SELECT shohin_id, shohin_mei, hanbai_tanka
  FROM Shohin2

-- データ型が不一致のためエラー  ※CAST式を使えばOK
SELECT shohin_id, hanbai_tanka
  FROM Shohin
UNION
SELECT shohin_id, torokubi
  FROM Shohin2

-- SELECT文はWHERE、GROUP BY、HAVINGどの句を使える　※ただし、ORDER BY句のみ全体として1つだけ最後に付ける
SELECT shohin_id, shohin_mei
  FROM Shohin
  WHERE shohin_bunrui = 'キッチン用品'
UNION
SELECT shohin_id, shohin_mei
  FROM Shohin2
  WHERE shohin_bunrui = 'キッチン用品'
ORDER BY shohin_id;

 shohin_id | shohin_mei
-----------+------------
 0004      | 包丁
 0005      | 圧力鍋
 0006      | フォーク
 0007      | おろしがね
 0010      | やかん
(5 行)

********************************************************************
  ALLオプション 重複行を残す集合演算
********************************************************************

SELECT shohin_id, shohin_mei
  FROM Shohin
UNION ALL
SELECT shohin_id, shohin_mei
  FROM Shohin2
ORDER BY shohin_id;

 shohin_id |   shohin_mei
-----------+----------------
 0001      | Tシャツ
 0001      | Tシャツ
 0002      | 穴あけパンチ
 0002      | 穴あけパンチ
 0003      | カッターシャツ
 0003      | カッターシャツ
 0004      | 包丁
 0005      | 圧力鍋
 0006      | フォーク
 0007      | おろしがね
 0008      | ボールペン
 0009      | 手袋
 0010      | やかん
(13 行)

********************************************************************
  INTERSECT テーブルの共通部分のレコードの選択
********************************************************************

SELECT shohin_id, shohin_mei
  FROM Shohin
INTERSECT
SELECT shohin_id, shohin_mei
  FROM Shohin2
ORDER BY shohin_id;

 shohin_id |   shohin_mei
-----------+----------------
 0001      | Tシャツ
 0002      | 穴あけパンチ
 0003      | カッターシャツ
(3 行)

********************************************************************
  EXCEPT レコードの引き算
********************************************************************

Shohin2テーブルの 0001 ~ 0003 と 0009 ~ 0010 が除外される

SELECT shohin_id, shohin_mei
  FROM Shohin
EXCEPT
SELECT shohin_id, shohin_mei
  FROM Shohin2
ORDER BY shohin_id;

 shohin_id | shohin_mei
-----------+------------
 0004      | 包丁
 0005      | 圧力鍋
 0006      | フォーク
 0007      | おろしがね
 0008      | ボールペン
(5 行)

********************************************************************
  結合 テーブルを列方向に連結する
********************************************************************

UNION や INTERSECT などの集合演算は「行」方向の結合（行数の増減をおこなう）※列数が一致していることが前提条件
一方で「列」を変化させるのは、結合（JOIN）

********************************************************************
  内部結合 INNER JOIN
********************************************************************

SELECT TS.tenpo_id, TS.tenpo_mei, TS.shohin_id, S.shohin_mei, S.hanbai_tanka
  FROM TenpoShohin AS TS INNER JOIN Shohin AS S
    ON TS.shohin_id = S.shohin_id
ORDER BY tenpo_id;

 tenpo_id | tenpo_mei | shohin_id |   shohin_mei   | hanbai_tanka
----------+-----------+-----------+----------------+--------------
 000A     | 東京      | 0002      | 穴あけパンチ   |          500
 000A     | 東京      | 0003      | カッターシャツ |         4000
 000A     | 東京      | 0001      | Tシャツ        |         1000
 000B     | 名古屋    | 0007      | おろしがね     |          880
 000B     | 名古屋    | 0002      | 穴あけパンチ   |          500
 000B     | 名古屋    | 0003      | カッターシャツ |         4000
 000B     | 名古屋    | 0004      | 包丁           |         3000
 000B     | 名古屋    | 0006      | フォーク       |          500
 000C     | 大阪      | 0007      | おろしがね     |          880
 000C     | 大阪      | 0006      | フォーク       |          500
 000C     | 大阪      | 0003      | カッターシャツ |         4000
 000C     | 大阪      | 0004      | 包丁           |         3000
 000D     | 福岡      | 0001      | Tシャツ        |         1000
(13 行)


内部結合のポイント１：FROM 句

  FROM TenpoShohin AS TS INNER JOIN Shohin AS S
  
  結合をおこなうとき、FROM句に複数のテーブルを記述する
  これを可能にするのは、INNER JOIN の働き


内部結合のポイント１：ON 句

  ON TS.shohin_id = S.shohin_id
  
  ON は内部結合をおこなう場合は必須
  記述する場所は FROM と WHERE の間
  shohin_idが「結合キー」


内部結合のポイント１：SELECT 句

  SELECT TS.tenpo_id, TS.tenpo_mei, TS.shohin_id, S.shohin_mei, S.hanbai_tanka

  「テーブルの別名.列名」で記述する（すべての列をこのように書くのが望ましい）
  どの列をどのテーブルから持ってきているのかを防ぐため

********************************************************************
  内部結合 INNER JOIN と WHERE を組み合わせる
********************************************************************

SELECT TS.tenpo_id, TS.tenpo_mei, TS.shohin_id, S.shohin_mei, S.hanbai_tanka
  FROM TenpoShohin TS INNER JOIN Shohin S
    ON TS.shohin_id = S.shohin_id
 WHERE TS.tenpo_id = '000A';

  tenpo_id | tenpo_mei | shohin_id |   shohin_mei   | hanbai_tanka
----------+-----------+-----------+----------------+--------------
 000A     | 東京      | 0001      | Tシャツ        |         1000
 000A     | 東京      | 0002      | 穴あけパンチ   |          500
 000A     | 東京      | 0003      | カッターシャツ |         4000
(3 行)

********************************************************************
  外部結合 OUTER JOIN
********************************************************************

SELECT TS.tenpo_id, TS.tenpo_mei, S.shohin_id, S.shohin_mei, S.hanbai_tanka
  FROM TenpoShohin AS TS RIGHT OUTER JOIN Shohin AS S
    ON TS.shohin_id = S.shohin_id
ORDER BY tenpo_id;

shohin_idの 0001 ~ 0005 の2つが外部結合のキーポイント
つまり、TempoShohinテーブルには存在していないものも一緒に出てくる

 tenpo_id | tenpo_mei | shohin_id |   shohin_mei   | hanbai_tanka
----------+-----------+-----------+----------------+--------------
 000A     | 東京      | 0002      | 穴あけパンチ   |          500
 000A     | 東京      | 0003      | カッターシャツ |         4000
 000A     | 東京      | 0001      | Tシャツ        |         1000
 000B     | 名古屋    | 0006      | フォーク       |          500
 000B     | 名古屋    | 0002      | 穴あけパンチ   |          500
 000B     | 名古屋    | 0003      | カッターシャツ |         4000
 000B     | 名古屋    | 0004      | 包丁           |         3000
 000B     | 名古屋    | 0007      | おろしがね     |          880
 000C     | 大阪      | 0006      | フォーク       |          500
 000C     | 大阪      | 0007      | おろしがね     |          880
 000C     | 大阪      | 0003      | カッターシャツ |         4000
 000C     | 大阪      | 0004      | 包丁           |         3000
 000D     | 福岡      | 0001      | Tシャツ        |         1000
          |           | 0005      | 圧力鍋         |         6800
          |           | 0008      | ボールペン     |          100
(15 行)


先ほどと同じクエリ結果（LEFTキーワード）

SELECT TS.tenpo_id, TS.tenpo_mei, S.shohin_id, S.shohin_mei, S.hanbai_tanka
  FROM Shohin AS S LEFT OUTER JOIN TenpoShohin AS TS
    ON TS.shohin_id = S.shohin_id
ORDER BY tenpo_id;

********************************************************************
  3つ以上のテーブルを使った結合
********************************************************************

SELECT TS.tenpo_id, TS.tenpo_mei, TS.shohin_id, S.shohin_mei, S.hanbai_tanka, ZS.zaiko_suryo
  FROM TenpoShohin AS TS INNER JOIN Shohin AS S
    ON TS.shohin_id = S.shohin_id
          INNER JOIN ZaikoShohin AS ZS
             ON TS.shohin_id = ZS.shohin_id
 WHERE ZS.souko_id = 'S001'
ORDER BY tenpo_id;


内部結合をおこなったFROM句に、再度INNER JOINによってZaiko Shohinテーブルを追加している
テーブルが4,5つと増えていっても、INNER JOINでテーブルを追加していくやり方は同じ
  FROM TenpoShohin AS TS INNER JOIN Shohin AS S
    ON TS.shohin_id = S.shohin_id
          INNER JOIN ZaikoShohin AS ZS
             ON TS.shohin_id = ZS.shohin_id

