USE vocab_app;

-- Tu dong gan image_url cho tat ca tu vung theo quy tac:
--   english -> lowercase -> thay khoang trang thanh "_" -> bo ky tu dac biet pho bien
-- Vi du:
--   "ice cream" -> assets/images/words/ice_cream.png
--   "mother-in-law" -> assets/images/words/mother_in_law.png
--
-- Luu y:
-- - Script chi gan duong dan; can dam bao file anh ton tai trong:
--   frontend/assets/images/words/
-- - Co the chay nhieu lan, khong gay loi.

UPDATE words
SET image_url = CONCAT(
  'assets/images/words/',
  TRIM(BOTH '_' FROM
    REPLACE(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(
                  REPLACE(
                    REPLACE(
                      LOWER(english),
                      ' ', '_'
                    ),
                    '-', '_'
                  ),
                  '''', ''
                ),
                '"', ''
              ),
              '(', ''
            ),
            ')', ''
          ),
          '/', '_'
        ),
        ',', ''
      ),
      '.', ''
    )
  ),
  '.png'
);

-- Kiem tra ket qua
SELECT id, english, image_url
FROM words
ORDER BY id;
