const oracledb = require('oracledb');

class Prestamo {
  constructor(noprestamo, idsucursal, cantidad) {
    this.noprestamo = noprestamo;
    this.idsucursal = idsucursal;
    this.cantidad = cantidad;
  }

  static async findAll() {
    let conn;
    try {
      conn = await oracledb.getConnection();
      const result = await conn.execute('SELECT * FROM prestamoGlobal');
      return result.rows;
    } catch (err) {
      throw err;
    } finally {
      if (conn) {
        await conn.close();
      }
    }
  }

  static async findById(noprestamo) {
    let conn;
    try {
      conn = await oracledb.getConnection();
      const result = await conn.execute(
        'SELECT * FROM prestamoGlobal WHERE noprestamo = :id',
        [noprestamo]
      );
      return result.rows[0];
    } catch (err) {
      throw err;
    } finally {
      if (conn) {
        await conn.close();
      }
    }
  }

  async save() {
    let conn;
    try {
      conn = await oracledb.getConnection();
      /*
      const result = await conn.execute(
        'INSERT INTO prestamo (noprestamo, idsucursal, cantidad) VALUES (:noprestamo, :idsucursal, :cantidad)',
        [this.noprestamo, this.idsucursal, this.cantidad]
      );
        */
      const result = await conn.execute(
        'BEGIN AltaPrestamo(:noprestamo, :idsucursal, :cantidad); END;',
        [this.noprestamo, this.idsucursal, this.cantidad]
      );
      
    
      console.log("Prestamo creado");
      await conn.execute('COMMIT');
    } catch (err) {
      throw err;
    } finally {
      if (conn) {
        await conn.close();
      }
    }
  }

  async update() {
    let conn;
    try {
      conn = await oracledb.getConnection();

      /*
      const result = await conn.execute(
        'UPDATE prestamo SET idsucursal = :idsucursal, cantidad = :cantidad WHERE noprestamo = :noprestamo',
        [this.idsucursal, this.cantidad, this.noprestamo]
      );
      */
      const result = await conn.execute(
        'BEGIN ActualizarPrestamo(:noprestamo, :idsucursal, :cantidad); END;',
        [this.noprestamo, this.idsucursal, this.cantidad]
      );

      console.log("Prestamo actualizado");
      await conn.execute('COMMIT');
    } catch (err) {
      throw err;
    } finally {
      if (conn) {
        await conn.close();
      }
    }
  }

  async delete() {
    let conn;
    try {
      conn = await oracledb.getConnection();

      /*
      const result = await conn.execute(
        'UPDATE prestamo SET idsucursal = :idsucursal, cantidad = :cantidad WHERE noprestamo = :noprestamo',
        [this.idsucursal, this.cantidad, this.noprestamo]
      );
      */
      const result = await conn.execute(
        'BEGIN BorrarPrestamo(:noprestamo, :idsucursal); END;',
        [this.noprestamo, this.idsucursal]
      );
      console.log("Prestamo eliminado");
      await conn.execute('COMMIT');
    } catch (err) {
      throw err;
    } finally {
      if (conn) {
        await conn.close();
      }
    }
  }

}

module.exports = Prestamo;
