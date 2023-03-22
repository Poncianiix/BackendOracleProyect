const express = require('express');
const Prestamo = require('../models/prestamo');

const router = express.Router();

// Obtener todos los préstamos
router.get('/', async (req, res) => {
  try {
    const prestamos = await Prestamo.findAll();
    res.status(200).json(prestamos);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error al obtener los préstamos');
  }
});

// Obtener un préstamo por ID
router.get('/:id', async (req, res) => {
  try {
    const prestamo = await Prestamo.findById(req.params.id);
    if (!prestamo) {
      res.status(404).send('Préstamo no encontrado');
    } else {
      res.status(200).json(prestamo);
    }
  } catch (err) {
    console.error(err);
    res.status(500).send('Error al obtener el préstamo');
  }
});

// Obtener un préstamo por sucursal

router.get('/sucursal/:sucursal', async (req, res) => {
  try {
    const prestamos = await Prestamo.findPrestamoPorSucursal();
    res.status(200).json(prestamos);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error al obtener los préstamos');
  }
});
// Crear un nuevo préstamo
router.post('/', async (req, res) => {
  const { noprestamo, idsucursal, cantidad } = req.body;
  const prestamo = new Prestamo(noprestamo, idsucursal, cantidad);

  prestamo.save()
  .then(() => {
    res.status(201).send('Préstamo creado exitosamente');
  })
  .catch((err) => {
    console.error(err);
    res.status(406).json({
        message: 'Error al crear el préstamo',
        error: err,
      })
  });
  /*
  try {
    await prestamo.save();
    res.status(201).send('Préstamo creado exitosamente');
  } catch (err) {
    console.error(err);
    res.status(500).send('Error al crear el préstamo');
  }
  */
});

// Actualizar un préstamo existente
router.put('/:id', async (req, res) => {
  const { idsucursal, cantidad } = req.body;
  const prestamo = new Prestamo(req.params.id, idsucursal, cantidad);
  prestamo.update()
  .then(() => {
    res.status(201).send('Préstamo actualizado exitosamente');
  })
  .catch((err) => {
    console.error(err);
    res.status(406).json({
        message: 'Error al actualizar el préstamo',
        error: err,
      })
  });
  /*
  try {
    await prestamo.update();
    res.status(200).send('Préstamo actualizado exitosamente');
  } catch (err) {
    console.error(err);
    res.status(500).send('Error al actualizar el préstamo');
  }
  */
});


// Eliminar un préstamo existente
router.delete('/:id', async (req, res) => {
  const { idsucursal, cantidad } = req.body;
  const prestamo = new Prestamo(req.params.id, idsucursal,cantidad);
  prestamo.delete()
  .then(() => {
    res.status(201).send('Préstamo eliminado exitosamente');
  })
  .catch((err) => {
    console.error(err);
    res.status(406).json({
        message: 'Error al eliminar el préstamo',
        error: err,
      })
  });
  /*
  try {
    await prestamo.delete();
    res.status(200).send('Préstamo eliminado exitosamente');
  } catch (err) {
    console.error(err);
    res.status(500).send('Error al eliminado el préstamo');
  }
  */
});

module.exports = router;
