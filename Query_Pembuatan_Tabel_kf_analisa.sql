--Kode SQL untuk pembuatan tabel kf_analisa dari hasil agregasi keempat tabel.
CREATE OR REPLACE TABLE kimia_farma.kf_analisa AS 
-- Berikut adalah CTE dengan nama transaksi yang melakukan perintah penggabungan dataset dan agregasi data di dalamnya untuk membuat tabel analisa.
WITH transaksi AS (
    SELECT 
    --Di bawah ini adalah data-data yang digabungkan dari dataset transaksi dengan simbol t, dataset kantor cabang dengan simbol kc, dan dataset produk dengan simbol p.
        t.transaction_id, 
        t.date, 
        t.branch_id, 
        kc.branch_name, 
        kc.kota, 
        kc.provinsi, 
        kc.rating AS rating_cabang,  
        t.customer_name, 
        p.product_id, 
        p.product_name, 
        p.price AS actual_price, 
        t.discount_percentage,

        -- Presentase laba yang seharusnya diterima dari harga obat. Ketentuan di bawah ini mengikuti aturan yang diberikan dari Kimia Farma pada Final Task yang diberikan.
        CASE 
            WHEN p.price <= 50000 THEN 0.10
            WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
            WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
            WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
            ELSE 0.30
        END AS persentase_gross_laba,

        -- nett_sales (harga setelah diskon)
        (p.price * (1 - t.discount_percentage / 100)) AS nett_sales,

        -- nett_profit (keuntungan yang diperoleh)
        ((p.price * (1 - t.discount_percentage / 100)) * 
        CASE 
            WHEN p.price <= 50000 THEN 0.10
            WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
            WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
            WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
            ELSE 0.30
        END) AS nett_profit,

        t.rating AS rating_transaksi  

    -- Di bawah ini adalah kode untuk menggabungkan data-data pada dataset transaksi, kantor cabang, dan produk.
    FROM kimia_farma.kf_final_transaction t
    JOIN kimia_farma.kf_kantor_cabang kc 
        ON t.branch_id = kc.branch_id
    JOIN kimia_farma.kf_product p 
        ON t.product_id = p.product_id
)

SELECT * FROM transaksi;