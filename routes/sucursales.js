const express = require('express');
const Sucursal = require('../models/sucursal');

const router = express.Router();

// Obtener todas las sucursales
router.get('/', async (req, res) => {

  try {
    const sucursales = await Sucursal.findAll();
    res.status(200).json(sucursales);
  } catch (err) {
    console.error(err);
    res.status(404).send('Error al obtener las sucursales');
  }
  
});

// Obtener una sucursal por ID
router.get('/:id', async (req, res) => {
    
  try {
    const sucursal = await Sucursal.findById(req.params.id);
    if (!sucursal) {
      res.status(404).send('Sucursal no encontrada');
    } else {
      res.status(200).json(sucursal);
    }
  } catch (err) {
    console.error(err);
    res.status(500).send('Error al obtener la sucursal');
  }
});

// Crear una nueva sucursal
router.post('/', async (req, res) => {
  const { idsucursal, nombresucursal, ciudadsucursal, activos, region } = req.body;
  const sucursal = new Sucursal(idsucursal, nombresucursal, ciudadsucursal, activos, region);

  sucursal.save()
  .then(() => {
    res.status(201).send('Sucursal creada exitosamente');
  })
  .catch((err) => {
    console.error(err);
    res.status(406).json({
        message: 'Error al crear la sucursal',
        error: err,
      })
  });
      /*
  try {
    await sucursal.save();
    res.status(201).send('Sucursal creada exitosamente');
    console.log("El codigo es:",res.statusCode);
  } catch (err) {
    console.error(err);200
    res.status(406).send('Error al crear la sucursal');
  }
  */
});

// Actualizar una sucursal existente
router.put('/:id', async (req, res) => {
  const {  nombresucursal, ciudadsucursal, activos, region } = req.body;
  const sucursal = new Sucursal(req.params.id, nombresucursal, ciudadsucursal, activos, region);
  /*
  try {
    await sucursal.update();
    res.status(201).send('Sucursal actualizada exitosamente');
  } catch (err) {
    console.error(err);
    res.status(406).send('Error al actualizar la sucursal');
  }
    */
  sucursal.update()
    .then(() => {
        res.status(201).send('Sucursal actualizada exitosamente');
        }
    )
    .catch((err) => {
        console.error(err);
        res.status(406).json({
            message: 'Error al actualizar la sucursal',
            error: err,
          })
    }
    );
});

// Eliminar una sucursal existente
router.delete('/:id', async (req, res) => {
    const {  nombresucursal, ciudadsucursal, activos, region } = req.body;
    const sucursal = new Sucursal(req.params.id,nombresucursal, ciudadsucursal, activos, region);

    
    sucursal.delete()
    .then(() => {
        res.status(201).send('Sucursal eliminada exitosamente');
        }
    )
    .catch((err) => {
        console.error(err);
        res.status(406).json({
            message: 'Error al eliminar la sucursal',
            error: err,
            })
    }
    );
    /*
    try {
    await sucursal.delete();
    res.status(200).send('Sucursal eliminada exitosamente');
  } catch (err) {
    console.error(err);
    res.status(400).send('Error al eliminar la sucursal',err);
  }
  */
});

module.exports = router;
