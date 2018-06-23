
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
  ビューの作りかた
********************************************************************

ビューはSELECT文を保存する（仮想テーブル）
一度ビューを作っておけば、簡単なSELECT文だけで、いつでも集計結果を得られ、使いまわしができる（毎回同じ式を書く必要がない）
テーブルは実際のデータを保存する

ShohinSumビュー
  CREATE VIEW ShohinSum (shohin_bunrui, cnt_shohin)　←ビューの列名
  AS
  SELECT shohin_bunrui, COUNT(*)　←ビュー定義の本体（普通のSELECT文）
      FROM Shohin
    GROUP BY shohin_bunrui;

ビューを使う
  SELECT shohin_bunrui, cnt_shohin
      FROM ShohinSum;　※テーブルの代わりにビューを指定する

クエリ結果
  shohin_bunrui | cnt_shohin
  ---------------+------------
  衣服          |          2
  事務用品      |          2
  キッチン用品  |          4
  (3 行)

********************************************************************
  サブクエリの作りかた
********************************************************************

サブクエリは、使い捨てのビュー（使い捨てSELECT文のこと）
ビューとは異なり、SELECT文の実行終了後に消去される
サブクエリには名前をつける必要がある
スカラ・サブクエリは「かならず１行１列だけの結果を返す」という制限をつけた特殊なサブクエリ

※内側にあるSELECT文がサブクエリ
※サブクエリにはかならず名前をつける
SELECT shohin_bunrui, "dmm.com"
    FROM (SELECT shohin_bunrui, COUNT(*) AS "dmm.com"  
            FROM Shohin
            GROUP BY shohin_bunrui) AS ShohinSum;

 shohin_bunrui | dmm.com
---------------+---------
 衣服          |       2
 事務用品      |       2
 キッチン用品  |       4
(3 行)

********************************************************************
  スカラ・サブクエリの作りかた
********************************************************************

WHERE句でスカラ・サブクエリを使う

販売単価が、全体の平均の販売単価より高い商品だけを検索する
  SELECT shohin_id, shohin_mei, hanbai_tanka
      FROM Shohin
    WHERE hanbai_tanka > AVG(hanbai_tanka);

WHERE句のなかに集約関数を書くことはできない（スカラ・サブクエリを使って解決する)
  ERROR:  aggregate functions are not allowed in WHERE
  行 3:   WHERE hanbai_tanka > AVG(hanbai_tanka);

全体の平均の販売単価
SELECT AVG(hanbai_tanka)
    FROM Shohin;

クエリ結果
            avg
  -----------------------
  2097.5000000000000000
  (1 行)

スカラ・サブクエリを使った式
  SELECT shohin_id, shohin_mei, hanbai_tanka
      FROM Shohin
    WHERE hanbai_tanka > (SELECT AVG(hanbai_tanka)　※AVG(hanbai_tanka)ではなく、普通のSELECT文を右辺に入れてあげる（2097.5)
                          FROM Shohin);

クエリ結果
  shohin_id |   shohin_mei   | hanbai_tanka
  -----------+----------------+--------------
  0003      | カッターシャツ |         4000
  0004      | 包丁           |         3000
  0005      | 圧力鍋         |         6800
  (3 行)

********************************************************************
  スカラ・サブクエリを書ける場所
********************************************************************

SELECT句でスカラ・サブクエリを使う

  商品一覧表のなかに商品全体の平均価格を含める
  SELECT shohin_id, 
        shohin_mei, 
        hanbai_tanka,
        (SELECT AVG(hanbai_tanka)  ※このSELECT文がスカラ・サブクエリ
            FROM Shohin) AS "dmm_avg_tanka"
      FROM Shohin;

  shohin_id |   shohin_mei   | hanbai_tanka |     dmm_avg_tanka
  -----------+----------------+--------------+-----------------------
  0001      | Tシャツ        |         1000 | 2097.5000000000000000
  0002      | 穴あけパンチ   |          500 | 2097.5000000000000000
  0003      | カッターシャツ |         4000 | 2097.5000000000000000
  0004      | 包丁           |         3000 | 2097.5000000000000000
  0005      | 圧力鍋         |         6800 | 2097.5000000000000000
  0006      | フォーク       |          500 | 2097.5000000000000000
  0007      | おろしがね     |          880 | 2097.5000000000000000
  0008      | ボールペン     |          100 | 2097.5000000000000000
  (8 行)


HAVING句でスカラ・サブクエリを使う

  商品分類ごとに計算した平均販売単価が、商品平均販売単価（2097.5）よりも高い
  SELECT shohin_bunrui, AVG(hanbai_tanka)
      FROM Shohin
    GROUP BY shohin_bunrui
  HAVING AVG(hanbai_tanka) > (SELECT AVG(hanbai_tanka) 　※このSELECT文がスカラ・サブクエリ
                                  FROM Shohin);

  shohin_bunrui |          avg
  ---------------+-----------------------
  衣服          | 2500.0000000000000000
  キッチン用品  | 2795.0000000000000000
  (2 行)


********************************************************************
  スカラ・サブクエリを使うときの注意点
********************************************************************

絶対にサブクエリが複数行を返さないようにする

  SELECT shohin_id, 
        shohin_mei, 
        hanbai_tanka,
        (SELECT AVG(hanbai_tanka)
            FROM Shohin
            GROUP BY shohin_bunrui) AS "dmm_avg_tanka"
      FROM Shohin;

  ERROR:  more than one row returned by a subquery used as an expression

  このSELECT文の返り値が複数行を返してしまう・・・
  SELECT AVG(hanbai_tanka)
      FROM Shohin
    GROUP BY shohin_bunrui;

********************************************************************
  相関サブクエリ
********************************************************************

相関サブクエリは、小分けにしたグループ内での比較をするときに使う
GROUP BY句と同じく、相関サブクエリも集合の「カット」という機能を持っている
相関サブクエリの結合条件は、サブクエリの中に書かないとエラーになるので注意

  商品分類ごとに、平均販売単価より高い商品を、商品分類のグループから選び出す

  商品分類ごとの平均販売単価（キッチン用品：2795 円／衣服：2500 円／事務用品：300 円）

    SELECT AVG(hanbai_tanka)
        FROM Shohin
      GROUP BY shohin_bunrui;
  
  上のSELECT文をそのままサブクエリとして、WHERE句に書いてしまうとエラーになってしまう・・・
  このサブクエリの結果が、2795, 2500, 300 と3行を返してしまい、スカラ・サブクエリにならないため！！

  そこで、相関サブクエリを使う
  サブクエリ内に追加したWHERE句の条件がミソ
  意味としては「各商品の販売単価と平均単価の比較を、同じ商品分類の中でおこなう」
  S1,S2のテーブルの別名は、今回比較対象となるテーブルが同じShohinなので、区別するために必要なもの
  「テーブル名.列名」の形式で記述する必要がある
  相関サブクエリは、テーブル全体ではなく、テーブルの一部のレコード集合に限定した比較をしたい場合に用いる


  SELECT shohin_bunrui, shohin_mei, hanbai_tanka
      FROM Shohin AS S1
    WHERE hanbai_tanka > (SELECT AVG(hanbai_tanka)
                              FROM Shohin AS S2
                            WHERE S1.shohin_bunrui = S2.shohin_bunrui  ※この条件が最大のミソ！
                            GROUP BY shohin_bunrui);
  

  結果をみると、商品分類ごとの平均販売単価（キッチン用品：2795 円／衣服：2500 円／事務用品：300 円）より販売単価が高い商品が選べている

  shohin_bunrui |   shohin_mei   | hanbai_tanka
  ---------------+----------------+--------------
  事務用品      | 穴あけパンチ   |          500
  衣服          | カッターシャツ |         4000
  キッチン用品  | 包丁           |         3000
  キッチン用品  | 圧力鍋         |         6800
  (4 行)

********************************************************************
  相関サブクエリでよく間違ってしまうミス
********************************************************************

結合条件をサブクエリの外側に移してしまうと・・・
相関名のスコープによりエラーとなってしまう！！

SELECT shohin_bunrui, shohin_mei, hanbai_tanka
    FROM Shohin AS S1　※テーブルS1のスコープはグローバル
  WHERE S1.shohin_bunrui = S2.shohin_bunrui　※テーブルS2がサブクエリのスコープ外となってしまうためエラー
    AND hanbai_tanka > (SELECT AVG(hanbai_tanka)
                            FROM Shohin AS S2
                          GROUP BY shohin_bunrui);

ERROR:  missing FROM-clause entry for table "s2"
行 3:     WHERE S1.shohin_bunrui = S2.shohin_bunrui

