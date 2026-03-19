from flask import Flask, flash, redirect, url_for, render_template, request, session
import mysql.connector
from flask_session import Session
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import os

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

# =======================================================================================================

# ====================================================================
#            <<------------------- Ruta principal ------------------->>
# ====================================================================
@app.route('/dashboard')
def dashboard():
    return render_template('dashboard.html')

@app.route('/generalpanel')
def generalpanel():
    return render_template('generalpanel.html')

@app.route('/')
@app.route('/index')
def index():
    return render_template('index.html')

@app.route('/login')
def login():
    return render_template('login.html')

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

@app.route('/olvidar_contraseña')
def olvidar_contraseña():
    return render_template('olvidar_contraseña.html')

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

@app.route('/registrar')
def registrar():
    return render_template('registrar.html')

@app.route('/VentanaModalActividad')
def VentanaModalActividad():
    return render_template('VentanaModalActividad.html')

@app.route('/VentanaModalDashboard')
def VentanaModalDashboard():
    return render_template('VentanaModalDashboard.html')

@app.route('/VentanaModalDependientes')
def VentanaModalDependientes():
    return render_template('VentanaModalDependientes.html')

@app.route('/verificacion')
def verificacion():
    return render_template('verificacion.html')

@app.route('/vista')
def vista():
    return render_template('vista.html')



# ------------------------------------------------------------------------------
if __name__ == '__main__':
    app.run(debug=True)