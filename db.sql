CREATE DATABASE IF NOT EXISTS `SEproyectoNA`
CREATE USER IF NOT EXISTS 'AhorrApp'@'localhost' IDENTIFIED BY 'Ah0rrApp_2026!';
GRANT ALL PRIVILEGES ON `SEproyectoNA`.* TO 'AhorrApp'@'localhost';

FLUSH PRIVILEGES;

DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE `SEproyectoNA`;

-- ------------------------------------------------------------------------------------
-- TRABAJO FINAL – BASE DE DATOS AHORRAPP 25/11/2025
-- ------------------------------------------------------------------------------------


CREATE TABLE IF NOT EXISTS USUARIOS (
    ID_usuario  INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del usuario',
    Nombre VARCHAR(100) NOT NULL COMMENT 'Nombre del usuario',
    Apellido VARCHAR(100) COMMENT 'Apellido del usuario',
    Rol ENUM('Administrador','Usuario') NOT NULL COMMENT 'Rol del usuario dentro del sistema',
    Password_hash VARCHAR(255) NOT NULL COMMENT 'Hash de la contraseña del usuario',
    Email VARCHAR(255) NOT NULL COMMENT 'Correo electrónico principal' 
        CHECK (Email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =======================
--     TABLA: categorias
-- =======================


CREATE TABLE IF NOT EXISTS CATEGORIAS (
    ID_categoria INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único de la categoría',
    Nombre VARCHAR(50) NOT NULL COMMENT 'Nombre de la categoría financiera',
    Color CHAR(7) COMMENT 'Color representativo de la categoría (formato HEX)' 
        CHECK (Color REGEXP '^#[0-9A-Fa-f]{6}$'),
    Icono VARCHAR(255) COMMENT 'Ruta o URL del icono de la categoría'
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- --------------------------
-- Módulos financieros y movimientos
-- --------------------------
CREATE TABLE IF NOT EXISTS MOVIMIENTOS (
    ID_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    Tipo_Flujo TINYINT NOT NULL COMMENT '1=Ingreso/Entrada, 2=Egreso/Salida',
    Subtipo_Modulo ENUM('Ahorro', 'Ingreso', 'Gasto', 'Deuda', 'Imprevisto') NOT NULL,
    Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- ==============================================
--     ENTRADA: Ahorros/Ingresos
-- ==============================================


CREATE TABLE IF NOT EXISTS ENTRADA (
    ID_entrada INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único de la entrada',
    ID_movimiento INT NOT NULL COMMENT 'Movimiento asociado a la entrada',
    FOREIGN KEY (ID_movimiento) REFERENCES MOVIMIENTOS(ID_movimiento)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS AHORROS (
    ID_ahorros INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del ahorro',
    ID_entrada INT NOT NULL COMMENT 'Tabla de entrada financiera asociada al ahorro',
    ID_categoria INT COMMENT 'Categoría asociada al ahorro',
    Monto DECIMAL(15,2) NOT NULL COMMENT 'Monto del ahorro' 
        CHECK (Monto >= 0),
    Descripcion VARCHAR(255) COMMENT 'Descripción del ahorro',
    Meta VARCHAR(100) COMMENT 'Meta u objetivo del ahorro',
    Fecha_registro DATE DEFAULT (CURRENT_DATE) COMMENT 'Fecha de registro del ahorro',
    Fecha_meta DATE COMMENT 'Fecha objetivo para cumplir la meta' 
        CHECK (Fecha_meta IS NULL OR Fecha_meta >= Fecha_registro),    
    FOREIGN KEY (ID_entrada) REFERENCES ENTRADA(ID_entrada)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
        ON DELETE SET NULL
        ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS INGRESOS (
    ID_ingresos INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del ingreso',
    ID_entrada INT NOT NULL COMMENT 'Tabla de entrada financiera asociada al ingreso',
    ID_categoria INT COMMENT 'Categoría asociada al ingreso',
    Monto DECIMAL(15,2) NOT NULL COMMENT 'Monto del ingreso' 
        CHECK (Monto >= 0),
    Descripcion VARCHAR(255) COMMENT 'Descripción del ingreso',
    Fuente VARCHAR(150) COMMENT 'Fuente del ingreso',
    Fecha_registro DATE DEFAULT (CURRENT_DATE) COMMENT 'Fecha de registro del ingreso',
    FOREIGN KEY (ID_entrada) REFERENCES ENTRADA(ID_entrada)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
        ON DELETE SET NULL
        ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ==============================================
--    SALIDA: Gastos/Imprevistos/Deudas
-- ==============================================

CREATE TABLE IF NOT EXISTS SALIDA (
    ID_salida INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único de la salida',
    ID_movimiento INT NOT NULL COMMENT 'Movimiento asociado a la tabla de salida',
    FOREIGN KEY (ID_movimiento) REFERENCES MOVIMIENTOS(ID_movimiento)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS GASTOS (
    ID_gastos INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del gasto',
    ID_salida INT NOT NULL COMMENT 'Tabla de salida financiera asociada al gasto',
    ID_categoria INT COMMENT 'Categoría asociada al gasto',
    Monto DECIMAL(15,2) NOT NULL COMMENT 'Monto del gasto' 
        CHECK (Monto >= 0),
    Descripcion VARCHAR(255) COMMENT 'Descripción del gasto',
    Fecha_registro DATE DEFAULT (CURRENT_DATE) COMMENT 'Fecha de registro del gasto',
    FOREIGN KEY (ID_salida) REFERENCES SALIDA(ID_salida)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
        ON DELETE SET NULL
        ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS IMPREVISTOS (
    ID_imprevistos INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del imprevisto',
    ID_salida INT NOT NULL COMMENT 'Tabla de salida financiera asociada al imprevisto',
    ID_categoria INT COMMENT 'Categoría asociada al imprevisto',
    Monto DECIMAL(15,2) NOT NULL COMMENT 'Monto del imprevisto' 
        CHECK (Monto >= 0),
    Causa VARCHAR(255) COMMENT 'Causa del gasto imprevisto',
    Fecha_registro DATE DEFAULT (CURRENT_DATE) COMMENT 'Fecha de registro del imprevisto',
    FOREIGN KEY (ID_salida) REFERENCES SALIDA(ID_salida)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
        ON DELETE SET NULL
        ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS DEUDAS (
    ID_deudas INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único de la deuda',
    ID_salida INT NOT NULL COMMENT 'Tabla de salida financiera asociada a la deuda',
    ID_categoria INT COMMENT 'Categoría asociada a la deuda',
    Monto DECIMAL(15,2) NOT NULL COMMENT 'Monto de la deuda' 
        CHECK (Monto >= 0),
    Fuente VARCHAR(150) NOT NULL COMMENT 'Fuente de la deuda',
    Descripcion VARCHAR(255) COMMENT 'Descripción de la deuda',
    Fecha_inicio DATE COMMENT 'Fecha de inicio de la deuda',
    Fecha_fin DATE COMMENT 'Fecha de finalización de la deuda',
    Estado ENUM('pendiente', 'pagada') COMMENT 'Estado actual de la deuda',
    FOREIGN KEY (ID_salida) REFERENCES SALIDA(ID_salida)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ID_categoria) REFERENCES CATEGORIAS(ID_categoria)
        ON DELETE SET NULL
        ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =======================
--     TABLA: dependientes
-- =======================


CREATE TABLE IF NOT EXISTS DEPENDIENTES (
    ID_dependientes  INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del dependiente',
    Nombre VARCHAR(100) NOT NULL COMMENT 'Nombre del dependiente',
    Ocupacion VARCHAR(150) COMMENT 'Ocupación del dependiente',
    Fecha_nacimiento DATE COMMENT 'Fecha de nacimiento del dependiente',
    Relacion VARCHAR(100) COMMENT 'Relación con el usuario',
    ID_usuario INT NOT NULL COMMENT 'Usuario al que pertenece el dependiente',
    FOREIGN KEY (ID_usuario) REFERENCES USUARIOS(ID_usuario)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =======================
--     TABLA: historial
-- =======================


CREATE TABLE IF NOT EXISTS HISTORIAL (
    ID_historial INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del historial',
    ID_usuario INT NOT NULL COMMENT 'Usuario que realizó la acción',
    accion VARCHAR(200) NOT NULL COMMENT 'Acción realizada por el usuario',
    detalles TEXT COMMENT 'Detalles adicionales de la acción',
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora del registro',
    FOREIGN KEY (ID_usuario) REFERENCES USUARIOS(ID_usuario)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =======================
--     TABLA: notificaciones
-- =======================


CREATE TABLE IF NOT EXISTS NOTIFICACIONES (
    ID_notificacion INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único de la notificación',
    ID_usuario INT NOT NULL COMMENT 'Usuario destinatario de la notificación',
    ID_historial INT NOT NULL COMMENT 'Historial relacionado con la notificación',
    Tipo ENUM('sistema','recordatorio','sugerencia') NOT NULL COMMENT 'Tipo de notificación',
    Mensaje TEXT NOT NULL COMMENT 'Contenido de la notificación',
    Fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación de la notificación',
    Leida BOOLEAN DEFAULT FALSE COMMENT 'Indica si la notificación fue leída',
    FOREIGN KEY (ID_usuario) REFERENCES USUARIOS(ID_usuario)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ID_historial) REFERENCES HISTORIAL(ID_historial)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------------------------------------------------------------------------------------
-- ========================= BORRAR =========================
-- -------------------------------------------------------------------------------------------
-- CREATE TABLE IF NOT EXISTS MOVIMIENTOS (
--     ID_movimiento INT AUTO_INCREMENT PRIMARY KEY,
--     Subtipo_Modulo ENUM('Ahorro', 'Ingreso', 'Gasto', 'Deuda', 'Imprevisto') NOT NULL,
    
--     -- Columna generada automáticamente:
--     -- Si es Ahorro o Ingreso -> 1 (Entrada)
--     -- Si es Gasto, Deuda o Imprevisto -> 2 (Salida)
--     Tipo_Flujo TINYINT GENERATED ALWAYS AS (
--         CASE 
--             WHEN Subtipo_Modulo IN ('Ahorro', 'Ingreso') THEN 1
--             WHEN Subtipo_Modulo IN ('Gasto', 'Deuda', 'Imprevisto') THEN 2
--         END
--     ) STORED COMMENT '1=Entrada, 2=Salida',
    
--     Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- ) ENGINE=InnoDB;

-- --------------------------
-- Módulos financieros y movimientos
-- --------------------------
-- CREATE TABLE IF NOT EXISTS MOVIMIENTOS (
--     ID_movimiento INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único del movimiento financiero',
--     ID_modulo INT NOT NULL COMMENT 'Módulo financiero al que pertenece el movimiento',
--     Tipo ENUM('Entrada','Salida') NOT NULL COMMENT 'Tipo de movimiento: entrada o salida',
--     FOREIGN KEY (ID_modulo) REFERENCES MODULOS_FINANCIEROS(ID_modulo)
--         ON DELETE CASCADE
--         ON UPDATE CASCADE
-- )ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;