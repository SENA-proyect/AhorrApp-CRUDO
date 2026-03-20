from flask import Flask, flash, redirect, url_for, render_template, request, session
import mysql.connector
from flask_session import Session
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
from flask_mail import Mail, Message
import os
import random #sera utilizado como token para el "olvidar_contraseña"

# ----------------------------
# Configuración de la app
# ----------------------------
app = Flask(__name__)
app.secret_key = 'clave_secreta'
app.config['SESSION_TYPE'] = 'filesystem'
Session(app)

# ----------------------------
# Configuración de base de datos (diccionario)
# ----------------------------
db_config = {
    'host': 'localhost',
    'user': 'AhorrApp',
    'password': 'Ah0rrApp_2026!',
    'database': 'SEproyectoNA'
}

def get_db_connection():
    return mysql.connector.connect(**db_config)
# --------------------------------------------------------
# Configuración de Mail (Ejemplo para Gmail)
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = 'proyectofinanzassena@gmail.com'
app.config['MAIL_PASSWORD'] = 'isep icnx hqlq qczi' # contraseña de aplicacion generada en Gmail para seguridad
mail = Mail(app)

# =======================================================================================================

# ====================================================================
#            <<------------------- Ruta principal ------------------->>
# ====================================================================
@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        # se capturan los datos del formulario (usa los 'name' agregados en el HTML)
        nombre = request.form.get('nombre')
        email_usuario = request.form.get('email')
        empresa = request.form.get('empresa')
        presupuesto = request.form.get('presupuesto')
        mensaje_texto = request.form.get('mensaje')

        # Creamos el correo
        msg = Message(subject=f"Nuevo contacto de {nombre}",
                      sender=app.config['MAIL_USERNAME'],
                      recipients=['proyectofinanzassena@gmail.com']) # A donde llegara el aviso del contacto
        
        msg.body = f"""
        Has recibido un nuevo mensaje de contacto:
        
        Nombre: {nombre}
        Empresa: {empresa}
        Email: {email_usuario}
        Presupuesto: {presupuesto}
        
        Mensaje:
        {mensaje_texto}
        """

        try:
            mail.send(msg)
            flash("¡Mensaje enviado con éxito!")
        except Exception as e:
            flash(f"Error al enviar: {str(e)}")
            
        return redirect(url_for('index'))

    return render_template('index.html')

# ===================================================================================
#            <<------------------- Login & Registrar ------------------->>
# ===================================================================================
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        
        try:
            # 1. Conectar usando tu función y buscar al usuario
            conn = get_db_connection()
            cur = conn.cursor()
            
            # Buscamos por Email
            query = "SELECT ID_usuario, Nombre, Password_hash, Rol FROM USUARIOS WHERE Email = %s"
            cur.execute(query, (email,))
            user = cur.fetchone() # Trae una tupla: (ID, Nombre, Hash, Rol)
            
            cur.close()
            conn.close()

            if user:
                # 2. Verificar el hash (user[2] es el Password_hash)
                if check_password_hash(user[2], password):
                    # 3. Guardar en sesión
                    session['user_id'] = user[0]
                    session['user_name'] = user[1]
                    session['user_role'] = user[3]
                    
                    flash(f"Bienvenido de nuevo, {user[1]}")
                    return redirect(url_for('dashboard'))
                else:
                    flash("Contraseña incorrecta", "danger")
            else:
                flash("El correo electrónico no está registrado", "warning")
                
        except mysql.connector.Error as err:
            print(f"Error en Login: {err}")
            flash("Error técnico al intentar iniciar sesión.")
            
        return redirect(url_for('login'))

    return render_template('login.html')

@app.route('/registrar', methods=['GET', 'POST'])
def registrar():
    if request.method == 'POST':
        nombres = request.form.get('nombres')
        apellido = request.form.get('apellido')
        correo = request.form.get('correo')
        password = request.form.get('contraseña')
        
        pass_encriptado = generate_password_hash(password)

        try:
            # 1. Obtener la conexión usando tu función
            conn = get_db_connection()
            cur = conn.cursor()
            
            # 2. Ejecutar el insert
            query = """
                INSERT INTO USUARIOS (Nombre, Apellido, Rol, Password_hash, Email) 
                VALUES (%s, %s, 'Usuario', %s, %s)
            """
            cur.execute(query, (nombres, apellido, pass_encriptado, correo))
            
            # 3. Guardar cambios y cerrar
            conn.commit()
            cur.close()
            conn.close()

            flash("Registro exitoso. ¡Ya puedes iniciar sesión!")
            return redirect(url_for('login'))

        except mysql.connector.Error as err:
            print(f"Error de base de datos: {err}")
            flash("Error al registrar: Verifica los datos o si el correo ya existe.")
            return redirect(url_for('registrar'))

    return render_template('registrar.html')

# ===================================================================================
#            <<------------------- MODULOS & DASHBOARD ------------------->>
# ===================================================================================

@app.route('/dashboard')
def dashboard():
    return render_template('dashboard.html')

# ------------------------------------------------------------------------------

@app.route('/moduloAhorros')
def moduloAhorros():
    return render_template('moduloAhorros.html')

@app.route('/moduloDependientes')
def moduloDependientes():
    return render_template('moduloDependientes.html')

@app.route('/moduloDeudas')
def moduloDeudas():
    return render_template('moduloDeudas.html')

@app.route('/moduloGastos')
def moduloGastos():
    return render_template('moduloGastos.html')

@app.route('/moduloImprevistos')
def moduloImprevistos():
    return render_template('moduloImprevistos.html')

@app.route('/moduloIngresos')
def moduloIngresos():
    return render_template('moduloIngresos.html')

@app.route('/modulosCategorias')
def modulosCategorias():
    return render_template('modulosCategorias.html')

# ===================================================================================
#            <<------------------- PANALES GENERALES (administrador) ------------------->>
# ===================================================================================

@app.route('/generalpanel')
def generalpanel():
    return render_template('generalpanel.html')

# -------------------------------------------------------------------------------

@app.route('/panelDependients')
def panelDependients():
    return render_template('panelDependients.html')

@app.route('/panelHistory')
def panelHistory():
    return render_template('panelHistory.html')

@app.route('/panelMovimients')
def panelMovimients():
    return render_template('panelMovimients.html')

@app.route('/panelUser')
def panelUser():
    return render_template('panelUser.html')

# ===================================================================================
#            <<------------------- VENTANAS MODALES ------------------->>
# ===================================================================================

@app.route('/VentanaModalActividad')
def VentanaModalActividad():
    return render_template('VentanaModalActividad.html')

@app.route('/VentanaModalDashboard')
def VentanaModalDashboard():
    return render_template('VentanaModalDashboard.html')

@app.route('/VentanaModalDependientes')
def VentanaModalDependientes():
    return render_template('VentanaModalDependientes.html')

# ===================================================================================
#            <<------------------- VERIFICACION & OLVIDAR_CONTRASEÑA & VISTA ------------------->>
# ===================================================================================

@app.route('/olvidar_contraseña', methods=['GET', 'POST'])
def olvidar_contraseña():
    if request.method == 'POST':
        email_destino = request.form.get('email')
        
        # 1. Verificar si el usuario existe en la DB
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT Nombre FROM USUARIOS WHERE Email = %s", (email_destino,))
        user = cur.fetchone()
        cur.close()
        conn.close()

        if user:
            # 2. Generar un código de recuperación (ej: 123456)
            codigo = str(random.randint(100000, 999999))
            
            # Guardamos el código y el email en la sesión para validarlo luego
            session['recovery_code'] = codigo
            session['recovery_email'] = email_destino

            # 3. Enviar el correo al usuario
            msg = Message(subject="Recuperación de Contraseña - AhorrApp",
                          sender=app.config['MAIL_USERNAME'],
                          recipients=[email_destino])
            
            msg.body = f"Hola {user[0]},\n\nTu código para restablecer la contraseña es: {codigo}\n\nSi no solicitaste esto, ignora este mensaje."
            
            try:
                mail.send(msg)
                flash("Código enviado a tu correo. Por favor revísalo.")
                return redirect(url_for('verificacion')) 
            except Exception as e:
                print(f"Error Mail: {e}")
                flash("Error al enviar el correo.")
        else:
            flash("El correo no está registrado en el sistema.")
            
    return render_template('olvidar_contraseña.html')

@app.route('/verificacion', methods=['GET', 'POST'])
def verificacion():
    if request.method == 'POST':
        codigo_ingresado = request.form.get('codigo')
        
        # Recuperamos el código que guardamos en la ruta anterior
        codigo_real = session.get('recovery_code')

        if codigo_ingresado == codigo_real:
            # Si coinciden, limpiamos el código de la sesión por seguridad
            # Pero dejamos el email para saber a quién le cambiaremos la clave
            session.pop('recovery_code', None) 
            flash("Código verificado. Ahora puedes cambiar tu contraseña.")
            return redirect(url_for('vista')) 
        else:
            flash("El código es incorrecto. Inténtalo de nuevo.")
            return redirect(url_for('verificacion'))

    return render_template('verificacion.html')

@app.route('/vista', methods=['GET', 'POST'])
def vista():
    # Verificamos que el usuario realmente haya pasado por la verificación
    email = session.get('recovery_email')
    if not email:
        flash("Acceso no autorizado. Inicia el proceso de nuevo.")
        return redirect(url_for('olvidar_contraseña'))

    if request.method == 'POST':
        nueva_pass = request.form.get('nueva_password')
        confirmar_pass = request.form.get('confirmar_password')

        if nueva_pass != confirmar_pass:
            flash("Las contraseñas no coinciden.")
            return redirect(url_for('vista'))

        # 1. Encriptar la nueva contraseña
        hash_nuevo = generate_password_hash(nueva_pass)

        try:
            # 2. Actualizar en la base de datos
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("""
                UPDATE USUARIOS 
                SET Password_hash = %s 
                WHERE Email = %s
            """, (hash_nuevo, email))
            
            conn.commit()
            cur.close()
            conn.close()

            # 3. Limpiar la sesión y redirigir
            session.pop('recovery_email', None)
            flash("Contraseña actualizada con éxito. Ya puedes iniciar sesión.")
            return redirect(url_for('login'))

        except Exception as e:
            print(f"Error al actualizar clave: {e}")
            flash("Hubo un error al guardar la nueva contraseña.")
            
    return render_template('vista.html')


# ¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿
# ===================================================================================
#            <<------------------- PENDIENTE ------------------->>
# ===================================================================================
# ?????????????????????????????????????????????????????????????????????????????????????


# ------------------------------------------------------------------------------
if __name__ == '__main__':
    app.run(debug=True)