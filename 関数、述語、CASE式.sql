
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
  CASE式
********************************************************************

CASE式はSQLの中で1,2を争う重要な機能
CASE式は条件分岐
CASE式には単純CASE式と検索CASE式の2種類がある


検索CASE式
<評価式>とは、列＝値のように、戻り値がTRUE/FALSE/UNKOWNになるような式のこと
CASE式を使うことで、SELECT文の結果を柔軟に組み替えられることができる

CASE WHEN <評価式> THEN <式>
     WHEN <評価式> THEN <式>
     WHEN <評価式> THEN <式>
     WHEN <評価式> THEN <式>

     ELSE <式>
END

CASE式の使い方
たとえば、商品分類を下記のような表示に変えて結果を得る

A:衣服
B:事務用品
C:キッチン用品

CASE式を使った場合

  SELECT shohin_mei, 
        CASE WHEN shohin_bunrui = '衣服'
        THEN 'A:' || shohin_bunrui
        WHEN shohin_bunrui = '事務用品'
        THEN 'B:' || shohin_bunrui
        WHEN shohin_bunrui = 'キッチン用品'
        THEN 'C:' || shohin_bunrui
        ELSE NULL
      END AS abc_shohin_bunrui
    FROM Shohin;


クエリ結果

    shohin_mei   | abc_shohin_bunrui
  ----------------+-------------------
  Tシャツ        | A:衣服
  穴あけパンチ   | B:事務用品
  カッターシャツ | A:衣服
  包丁           | C:キッチン用品
  圧力鍋         | C:キッチン用品
  フォーク       | C:キッチン用品
  おろしがね     | C:キッチン用品
  ボールペン     | B:事務用品
  (8 行)


このCASE式の６行が、これで１つの列（abc_shohin_bunrui）に相当する

       CASE WHEN shohin_bunrui = '衣服'
       THEN 'A:' || shohin_bunrui
       WHEN shohin_bunrui = '事務用品'
       THEN 'B:' || shohin_bunrui
       WHEN shohin_bunrui = 'キッチン用品'
       THEN 'C:' || shohin_bunrui

ELSE NULL は「それ以外の場合はNULL」という意味
ELSE 句は省略可能だが、省略しないようにする

最後の END は省略不可能、絶対に書き忘れないようにする
END AS abc_shohin_bunrui

********************************************************************
  CASE式を使った行列変換
********************************************************************

商品分類ごとに販売単価を合計した結果
商品分類の列を GROUP BY 句で集約キーとして使っても、
結果は「行」として出力される（「列」として並べることはできない）

  SELECT shohin_bunrui, SUM(hanbai_tanka) AS "dmm_sum"
      FROM Shohin
    GROUP BY shohin_bunrui;

  shohin_bunrui | dmm_sum
  ---------------+---------
  衣服          |    5000
  事務用品      |     600
  キッチン用品  |   11180
  (3 行)


CASE式を使った場合
「列」として結果を得るには、SUM関数の中でCASE式を使うことで「列」を3つ作ってしまう


  SELECT SUM(CASE WHEN shohin_bunrui = '衣服' 
                  THEN hanbai_tanka ELSE 0 END) AS "衣服 販売単価合計",
         SUM(CASE WHEN shohin_bunrui = 'キッチン用品' 
                  THEN hanbai_tanka ELSE 0 END) AS  "キッチン用品 販売単価合計",
         SUM(CASE WHEN shohin_bunrui = '事務用品' 
                  THEN hanbai_tanka ELSE 0 END) AS  "事務用品 販売単価合計"
    FROM Shohin;

クエリ結果

 衣服 販売単価合計 | キッチン用品 販売単価合計 | 事務用品 販売単価合計
-------------------+---------------------------+-----------------------
            5000 |                  11180 |                600
(1 行)