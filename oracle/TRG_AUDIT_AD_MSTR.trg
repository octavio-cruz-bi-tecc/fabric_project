CREATE OR REPLACE TRIGGER QAD.TRG_AUDIT_AD_MSTR
AFTER INSERT OR UPDATE OR DELETE ON QAD.AD_MSTR FOR EACH ROW
DECLARE
  v_record_id      INTEGER;
  v_company_code   VARCHAR2(8);
  v_windows_user   VARCHAR2(80);
  v_operation_type CHAR(1);
BEGIN
  -- 1. Determinar el tipo de operación
  IF INSERTING THEN
    v_operation_type := 'I';
  ELSIF UPDATING THEN
    v_operation_type := 'U';
  ELSIF DELETING THEN
    v_operation_type := 'D';
  END IF;
-- 2. Capturar los valores de la clave de la fila afectada
  IF v_operation_type IN ('I', 'U') THEN
    v_record_id    := :NEW.PROGRESS_RECID;
    v_company_code := :NEW.AD_DOMAIN;
ELSE
    v_record_id    := :OLD.PROGRESS_RECID;
    v_company_code := :OLD.AD_DOMAIN;
  END IF;
-- ¿ 3. LA CORRECCIÓN: Solo ejecutar el log si las claves tienen valor
  IF v_record_id IS NOT NULL AND v_company_code IS NOT NULL THEN
-- 4. Leer el usuario de Windows desde el contexto de la sesión
    v_windows_user := SYS_CONTEXT('USERENV', 'OS_USER');
-- 5. Inserta o actualiza el log en la tabla UPDT_LOG
    MERGE INTO UPDT_LOG log
    USING (
      SELECT 'AD_MSTR' AS table_n, v_record_id AS record_i, v_company_code AS company_c FROM dual
    ) src
    ON (log.TABLE_NAME = src.table_n AND log.RECORD_ID = src.record_i AND log.COMPANY_CODE = src.company_c)
    WHEN MATCHED THEN
      UPDATE SET
        log.UPDATED_AT = SYSDATE,
        log.UPDATED_BY = NVL(v_windows_user, USER),
        log.OPERATION_TYPE = v_operation_type
    WHEN NOT MATCHED THEN
      INSERT (TABLE_NAME, RECORD_ID, COMPANY_CODE, UPDATED_AT, UPDATED_BY, OPERATION_TYPE)
      VALUES (src.table_n, src.record_i, src.company_c, SYSDATE, NVL(v_windows_user, USER), v_operation_type);
END IF; -- Fin de la condición de seguridad
END;
/
