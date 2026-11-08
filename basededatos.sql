BEGIN;
CREATE TABLE editorial (
    editorial_id  INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    name          VARCHAR(150) NOT NULL
);
CREATE TABLE subject (
    subject_id  INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    name        VARCHAR(100) NOT NULL
);
CREATE TABLE language (
    language_id  INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    name         VARCHAR(60) NOT NULL
);
CREATE TABLE place_of_origin (
    place_id  INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    name      VARCHAR(100) NOT NULL
);
CREATE TABLE label (
    label_id  INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    name      VARCHAR(100) NOT NULL
);
CREATE TABLE acquisition_method (
    acquisition_method_id  INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    name                   VARCHAR(100) NOT NULL
);
CREATE TABLE location (
    location_id  INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    name         VARCHAR(100) NOT NULL
);
CREATE TABLE shelf (
    shelf_id      INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    shelf_number  SMALLINT NOT NULL,
    letter        VARCHAR(2) NOT NULL,
    location_id   INTEGER NOT NULL
);
CREATE TABLE author (
    author_id   INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    name1       VARCHAR(50) NOT NULL,
    name2       VARCHAR(50),
    last_name1  VARCHAR(50) NOT NULL,
    last_name2  VARCHAR(50),
    place_id    INTEGER NOT NULL
);
CREATE TABLE book (
    book_id               INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    title                 VARCHAR(250) NOT NULL,
    physical_description  VARCHAR(500),
    publication_year      SMALLINT,
    isbn                  VARCHAR(20) NOT NULL,
    edition               VARCHAR(50),
    editorial_id          INTEGER NOT NULL,
    subject_id            INTEGER NOT NULL,
    language_id           INTEGER NOT NULL,
    place_id              INTEGER NOT NULL
);
CREATE TABLE book_author (
    book_id    INTEGER NOT NULL,
    author_id  INTEGER NOT NULL
);
CREATE TABLE copy (
    copy_number            INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    barcode                VARCHAR(30) NOT NULL,
    inventory_number       VARCHAR(30) NOT NULL,
    volume                 VARCHAR(20),
    price                  NUMERIC(10,2),
    acquisition_date       DATE,
    collection             VARCHAR(100),
    status                 VARCHAR(20) DEFAULT 'AVAILABLE' NOT NULL,
    book_id                INTEGER NOT NULL,
    shelf_id               INTEGER NOT NULL,
    label_id               INTEGER NOT NULL,
    acquisition_method_id  INTEGER NOT NULL
);
CREATE TABLE customer (
    customer_code  INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    name1          VARCHAR(50) NOT NULL,
    name2          VARCHAR(50),
    last_name1     VARCHAR(50) NOT NULL,
    last_name2     VARCHAR(50),
    email          VARCHAR(150) NOT NULL,
    phone          VARCHAR(20) NOT NULL
);
CREATE TABLE employee (
    employee_id  INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    name1        VARCHAR(50) NOT NULL,
    name2        VARCHAR(50),
    last_name1   VARCHAR(50) NOT NULL,
    last_name2   VARCHAR(50),
    email        VARCHAR(150) NOT NULL,
    phone        VARCHAR(20) NOT NULL
);
CREATE TABLE reservation (
    reservation_id        INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    reservation_datetime  TIMESTAMP NOT NULL,
    return_date           TIMESTAMP,
    status                VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL,
    customer_code         INTEGER NOT NULL,
    employee_id           INTEGER NOT NULL
);
CREATE TABLE reservation_detail (
    detail_id       INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    reservation_id  INTEGER NOT NULL,
    copy_number     INTEGER NOT NULL
);
CREATE TABLE audit (
    audit_id            BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    table_name          VARCHAR(63)  NOT NULL,
    record_id           VARCHAR(200) NOT NULL,
    operation           VARCHAR(6)   NOT NULL,
    old_values          JSONB,
    new_values          JSONB,
    operation_datetime  TIMESTAMPTZ  DEFAULT CURRENT_TIMESTAMP NOT NULL,
    db_user             VARCHAR(63)  DEFAULT CURRENT_USER NOT NULL,
    description         TEXT
);
ALTER TABLE editorial          ADD CONSTRAINT editorial_pk          PRIMARY KEY (editorial_id);
ALTER TABLE subject            ADD CONSTRAINT subject_pk            PRIMARY KEY (subject_id);
ALTER TABLE language           ADD CONSTRAINT language_pk           PRIMARY KEY (language_id);
ALTER TABLE place_of_origin    ADD CONSTRAINT place_of_origin_pk    PRIMARY KEY (place_id);
ALTER TABLE label              ADD CONSTRAINT label_pk              PRIMARY KEY (label_id);
ALTER TABLE acquisition_method ADD CONSTRAINT acquisition_method_pk PRIMARY KEY (acquisition_method_id);
ALTER TABLE location           ADD CONSTRAINT location_pk           PRIMARY KEY (location_id);
ALTER TABLE shelf              ADD CONSTRAINT shelf_pk              PRIMARY KEY (shelf_id);
ALTER TABLE author             ADD CONSTRAINT author_pk             PRIMARY KEY (author_id);
ALTER TABLE book               ADD CONSTRAINT book_pk               PRIMARY KEY (book_id);
ALTER TABLE book_author        ADD CONSTRAINT book_author_pk        PRIMARY KEY (book_id, author_id);
ALTER TABLE copy               ADD CONSTRAINT copy_pk               PRIMARY KEY (copy_number);
ALTER TABLE customer           ADD CONSTRAINT customer_pk           PRIMARY KEY (customer_code);
ALTER TABLE employee           ADD CONSTRAINT employee_pk           PRIMARY KEY (employee_id);
ALTER TABLE reservation        ADD CONSTRAINT reservation_pk        PRIMARY KEY (reservation_id);
ALTER TABLE reservation_detail ADD CONSTRAINT reservation_detail_pk PRIMARY KEY (detail_id);
ALTER TABLE audit              ADD CONSTRAINT audit_pk              PRIMARY KEY (audit_id);
ALTER TABLE book     ADD CONSTRAINT book_isbn_un      UNIQUE (isbn);
ALTER TABLE copy     ADD CONSTRAINT copy_barcode_un   UNIQUE (barcode);
ALTER TABLE copy     ADD CONSTRAINT copy_inventory_un UNIQUE (inventory_number);
ALTER TABLE customer ADD CONSTRAINT customer_email_un UNIQUE (email);
ALTER TABLE employee ADD CONSTRAINT employee_email_un UNIQUE (email);
ALTER TABLE reservation_detail
    ADD CONSTRAINT res_detail_un UNIQUE (reservation_id, copy_number);
ALTER TABLE label    ADD CONSTRAINT label_name_un     UNIQUE (name);
ALTER TABLE copy        ADD CONSTRAINT copy_status_ck
    CHECK (status IN ('AVAILABLE','RESERVED','LOANED','DAMAGED','LOST'));
ALTER TABLE reservation ADD CONSTRAINT reservation_status_ck
    CHECK (status IN ('ACTIVE','COMPLETED','CANCELLED'));
ALTER TABLE copy        ADD CONSTRAINT copy_price_ck CHECK (price >= 0);
ALTER TABLE label       ADD CONSTRAINT label_name_ck
    CHECK (name IN ('ROJO','VERDE','AMARILLO'));
ALTER TABLE reservation ADD CONSTRAINT reservation_dates_ck
    CHECK (return_date IS NULL OR return_date > reservation_datetime);
ALTER TABLE audit       ADD CONSTRAINT audit_operation_ck
    CHECK (operation IN ('INSERT','UPDATE','DELETE'));
ALTER TABLE shelf ADD CONSTRAINT shelf_location_fk
    FOREIGN KEY (location_id) REFERENCES location (location_id);
ALTER TABLE author ADD CONSTRAINT author_place_fk
    FOREIGN KEY (place_id) REFERENCES place_of_origin (place_id);
ALTER TABLE book ADD CONSTRAINT book_editorial_fk
    FOREIGN KEY (editorial_id) REFERENCES editorial (editorial_id);
ALTER TABLE book ADD CONSTRAINT book_subject_fk
    FOREIGN KEY (subject_id) REFERENCES subject (subject_id);
ALTER TABLE book ADD CONSTRAINT book_language_fk
    FOREIGN KEY (language_id) REFERENCES language (language_id);
ALTER TABLE book ADD CONSTRAINT book_place_fk
    FOREIGN KEY (place_id) REFERENCES place_of_origin (place_id);
ALTER TABLE book_author ADD CONSTRAINT book_author_book_fk
    FOREIGN KEY (book_id) REFERENCES book (book_id);
ALTER TABLE book_author ADD CONSTRAINT book_author_author_fk
    FOREIGN KEY (author_id) REFERENCES author (author_id);
ALTER TABLE copy ADD CONSTRAINT copy_book_fk
    FOREIGN KEY (book_id) REFERENCES book (book_id);
ALTER TABLE copy ADD CONSTRAINT copy_shelf_fk
    FOREIGN KEY (shelf_id) REFERENCES shelf (shelf_id);
ALTER TABLE copy ADD CONSTRAINT copy_label_fk
    FOREIGN KEY (label_id) REFERENCES label (label_id);
ALTER TABLE copy ADD CONSTRAINT copy_acq_method_fk
    FOREIGN KEY (acquisition_method_id) REFERENCES acquisition_method (acquisition_method_id);
ALTER TABLE reservation ADD CONSTRAINT reservation_customer_fk
    FOREIGN KEY (customer_code) REFERENCES customer (customer_code);
ALTER TABLE reservation ADD CONSTRAINT reservation_employee_fk
    FOREIGN KEY (employee_id) REFERENCES employee (employee_id);
ALTER TABLE reservation_detail ADD CONSTRAINT res_detail_reservation_fk
    FOREIGN KEY (reservation_id) REFERENCES reservation (reservation_id);
ALTER TABLE reservation_detail ADD CONSTRAINT res_detail_copy_fk
    FOREIGN KEY (copy_number) REFERENCES copy (copy_number);
CREATE INDEX shelf_location_ix       ON shelf (location_id);
CREATE INDEX author_place_ix         ON author (place_id);
CREATE INDEX book_editorial_ix       ON book (editorial_id);
CREATE INDEX book_subject_ix         ON book (subject_id);
CREATE INDEX book_language_ix        ON book (language_id);
CREATE INDEX book_place_ix           ON book (place_id);
CREATE INDEX book_author_author_ix   ON book_author (author_id);
CREATE INDEX copy_book_ix            ON copy (book_id);
CREATE INDEX copy_shelf_ix           ON copy (shelf_id);
CREATE INDEX copy_label_ix           ON copy (label_id);
CREATE INDEX copy_acq_method_ix      ON copy (acquisition_method_id);
CREATE INDEX reservation_customer_ix ON reservation (customer_code);
CREATE INDEX reservation_employee_ix ON reservation (employee_id);
CREATE INDEX res_detail_copy_ix      ON reservation_detail (copy_number);
CREATE INDEX reservation_active_period_ix
    ON reservation (reservation_datetime, return_date)
    WHERE status = 'ACTIVE';
CREATE INDEX audit_table_record_ix ON audit (table_name, record_id);
CREATE INDEX audit_datetime_ix     ON audit (operation_datetime);
INSERT INTO label (name) VALUES ('ROJO'), ('VERDE'), ('AMARILLO');
CREATE FUNCTION fn_audit_row()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_old  JSONB;
    v_new  JSONB;
    v_src  JSONB;
    v_id   TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_new := to_jsonb(NEW);
        v_src := v_new;
    ELSIF TG_OP = 'UPDATE' THEN
        v_old := to_jsonb(OLD);
        v_new := to_jsonb(NEW);
        v_src := v_new;
        IF v_old = v_new THEN
            RETURN NULL;
        END IF;
    ELSE
        v_old := to_jsonb(OLD);
        v_src := v_old;
    END IF;
    SELECT string_agg(v_src ->> a.col, ',' ORDER BY a.ord)
      INTO v_id
      FROM unnest(TG_ARGV) WITH ORDINALITY AS a(col, ord);
    INSERT INTO audit (table_name, record_id, operation, old_values, new_values)
    VALUES (TG_TABLE_NAME, v_id, TG_OP, v_old, v_new);
    RETURN NULL;
END;
$$;
CREATE TRIGGER trg_audit_author
    AFTER INSERT OR UPDATE OR DELETE ON author
    FOR EACH ROW EXECUTE FUNCTION fn_audit_row('author_id');
CREATE TRIGGER trg_audit_book
    AFTER INSERT OR UPDATE OR DELETE ON book
    FOR EACH ROW EXECUTE FUNCTION fn_audit_row('book_id');
CREATE TRIGGER trg_audit_book_author
    AFTER INSERT OR UPDATE OR DELETE ON book_author
    FOR EACH ROW EXECUTE FUNCTION fn_audit_row('book_id', 'author_id');
CREATE TRIGGER trg_audit_copy
    AFTER INSERT OR UPDATE OR DELETE ON copy
    FOR EACH ROW EXECUTE FUNCTION fn_audit_row('copy_number');
CREATE TRIGGER trg_audit_customer
    AFTER INSERT OR UPDATE OR DELETE ON customer
    FOR EACH ROW EXECUTE FUNCTION fn_audit_row('customer_code');
CREATE TRIGGER trg_audit_employee
    AFTER INSERT OR UPDATE OR DELETE ON employee
    FOR EACH ROW EXECUTE FUNCTION fn_audit_row('employee_id');
CREATE TRIGGER trg_audit_reservation
    AFTER INSERT OR UPDATE OR DELETE ON reservation
    FOR EACH ROW EXECUTE FUNCTION fn_audit_row('reservation_id');
CREATE TRIGGER trg_audit_reservation_detail
    AFTER INSERT OR UPDATE OR DELETE ON reservation_detail
    FOR EACH ROW EXECUTE FUNCTION fn_audit_row('detail_id');
CREATE FUNCTION fn_reservation_validate_copy(
    p_reservation_id  INTEGER,
    p_copy_number     INTEGER,
    p_start           TIMESTAMP,
    p_end             TIMESTAMP,
    p_status          VARCHAR
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_label_id  INTEGER;
    v_label     VARCHAR(100);
    v_conflict  INTEGER;
BEGIN
    IF p_status <> 'ACTIVE' THEN
        RETURN;
    END IF;
    IF current_setting('transaction_isolation') <> 'read committed' THEN
        RAISE EXCEPTION
            'La validación de reservas requiere READ COMMITTED (nivel actual: %).',
            current_setting('transaction_isolation')
            USING ERRCODE = 'invalid_transaction_state';
    END IF;
    SELECT label_id
      INTO v_label_id
      FROM copy
     WHERE copy_number = p_copy_number
       FOR NO KEY UPDATE;
    IF NOT FOUND THEN
        RETURN;
    END IF;
    SELECT name INTO v_label FROM label WHERE label_id = v_label_id;
    IF v_label = 'AMARILLO' THEN
        RAISE EXCEPTION
            'La copia % tiene etiqueta AMARILLO (referencia, solo consulta interna) y no se puede reservar.',
            p_copy_number
            USING ERRCODE = 'check_violation';
    END IF;
    IF p_end IS NULL THEN
        RAISE EXCEPTION
            'Una reserva ACTIVE debe tener fecha y hora de finalización (return_date).'
            USING ERRCODE = 'check_violation';
    END IF;
    SELECT r.reservation_id
      INTO v_conflict
      FROM reservation_detail d
      JOIN reservation r ON r.reservation_id = d.reservation_id
     WHERE d.copy_number = p_copy_number
       AND r.status = 'ACTIVE'
       AND r.return_date IS NOT NULL
       AND r.reservation_id IS DISTINCT FROM p_reservation_id
       AND r.reservation_datetime < p_end
       AND p_start < r.return_date
     LIMIT 1;
    IF FOUND THEN
        RAISE EXCEPTION
            'La copia % ya tiene la reserva activa % que se superpone con el periodo solicitado.',
            p_copy_number, v_conflict
            USING ERRCODE = 'exclusion_violation';
    END IF;
END;
$$;
CREATE FUNCTION fn_reservation_detail_validate()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_start   TIMESTAMP;
    v_end     TIMESTAMP;
    v_status  VARCHAR(20);
BEGIN
    SELECT reservation_datetime, return_date, status
      INTO v_start, v_end, v_status
      FROM reservation
     WHERE reservation_id = NEW.reservation_id
       FOR SHARE;
    IF NOT FOUND THEN
        RETURN NEW;
    END IF;
    PERFORM fn_reservation_validate_copy(
        NEW.reservation_id, NEW.copy_number, v_start, v_end, v_status);
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_reservation_detail_validate
    BEFORE INSERT OR UPDATE OF reservation_id, copy_number
    ON reservation_detail
    FOR EACH ROW EXECUTE FUNCTION fn_reservation_detail_validate();
CREATE FUNCTION fn_reservation_validate()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_copy  INTEGER;
BEGIN
    IF NEW.status = 'ACTIVE' AND NEW.return_date IS NULL THEN
        RAISE EXCEPTION
            'Una reserva ACTIVE debe tener fecha y hora de finalización (return_date).'
            USING ERRCODE = 'check_violation';
    END IF;
    IF TG_OP = 'UPDATE' AND NEW.status = 'ACTIVE' THEN
        FOR v_copy IN
            SELECT copy_number
              FROM reservation_detail
             WHERE reservation_id = NEW.reservation_id
             ORDER BY copy_number
        LOOP
            PERFORM fn_reservation_validate_copy(
                NEW.reservation_id, v_copy,
                NEW.reservation_datetime, NEW.return_date, NEW.status);
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_reservation_validate
    BEFORE INSERT OR UPDATE OF reservation_datetime, return_date, status
    ON reservation
    FOR EACH ROW EXECUTE FUNCTION fn_reservation_validate();
CREATE FUNCTION fn_copy_label_validate()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_label        VARCHAR(100);
    v_reservation  INTEGER;
BEGIN
    SELECT name INTO v_label FROM label WHERE label_id = NEW.label_id;
    IF v_label = 'AMARILLO' THEN
        IF current_setting('transaction_isolation') <> 'read committed' THEN
            RAISE EXCEPTION
                'La validación de etiquetas requiere READ COMMITTED (nivel actual: %).',
                current_setting('transaction_isolation')
                USING ERRCODE = 'invalid_transaction_state';
        END IF;
        SELECT r.reservation_id
          INTO v_reservation
          FROM reservation_detail d
          JOIN reservation r ON r.reservation_id = d.reservation_id
         WHERE d.copy_number = NEW.copy_number
           AND r.status = 'ACTIVE'
         LIMIT 1;
        IF FOUND THEN
            RAISE EXCEPTION
                'La copia % tiene la reserva activa % y no puede cambiar a etiqueta AMARILLO.',
                NEW.copy_number, v_reservation
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_copy_label_validate
    BEFORE UPDATE OF label_id ON copy
    FOR EACH ROW
    WHEN (OLD.label_id IS DISTINCT FROM NEW.label_id)
    EXECUTE FUNCTION fn_copy_label_validate();
CREATE FUNCTION fn_label_catalog_immutable()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION
        'El catálogo de etiquetas es fijo; no se permite modificar ni eliminar etiquetas.'
        USING ERRCODE = 'integrity_constraint_violation';
END;
$$;
CREATE TRIGGER trg_label_catalog_immutable
    BEFORE UPDATE OR DELETE ON label
    FOR EACH ROW EXECUTE FUNCTION fn_label_catalog_immutable();
llaves compuestas separadas por coma';
recibe las columnas PK como argumentos';
COMMIT;
