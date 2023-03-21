const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const oracledb = require('oracledb');
const prestamosRoutes = require('./routes/prestamos');
const sucursalRoutes = require('./routes/sucursales');

const app = express();

app.use(bodyParser.json());
app.use(express.json());

const PORT = process.env.PORT || 3000;

// Conectar con la base de datos
const connectToDb = async () => {
  try {
    await oracledb.createPool({
        user: 'USER1A',
        password: '123456',
        connectString: '172.17.0.2:1521/XE'
      });
      
    console.log('Conexión exitosa a la base de datos');
  } catch (err) {
    console.error(err);
  }
};

// Definir rutas
app.use(cors());
app.use('/prestamos', prestamosRoutes);
app.use('/sucursales', sucursalRoutes);

// Iniciar servidor
connectToDb().then(() => {
  app.listen(PORT, () => {
    console.log(`Servidor iniciado en el puerto ${PORT}`);
  });
}).catch((err) => {
  console.error(err);
});
