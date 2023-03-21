const oracledb = require('oracledb');

class Sucursal {
  constructor(idsucursal, nombresucursal, ciudadsucursal, activos, region) {
    this.idsucursal = idsucursal;
    this.nombresucursal = nombresucursal;
    this.ciudadsucursal = ciudadsucursal;
    this.activos = activos;
    this.region = region;
  }

  static async findAll() {
    let conn;
    try {
      conn = await oracledb.getConnection();
      const result = await conn.execute('SELECT * FROM sucursalGlobal');
      return result.rows;
    } catch (err) {
      throw err;
    } finally {
      if (conn) {
        await conn.close();
      }
    }
  }

  static async findById(idsucursal) {
    let conn;
    try {
      conn = await oracledb.getConnection();
      const result = await conn.execute(
        'SELECT * FROM sucursalGlobal WHERE idsucursal = :id',
        [idsucursal]
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
        'INSERT INTO sucursal (idsucursal, nombresucursal, ciudadsucursal, activos, region) VALUES (:idsucursal, :nombresucursal, :ciudadsucursal, :activos, :region)',
        [this.idsucursal, this.nombresucursal, this.ciudadsucursal, this.activos, this.region]
      );
    */
      const result = await conn.execute(
        'BEGIN AltaSucursal(:idsucursal, :nombresucursal, :ciudadsucursal, :activos, :region); END;',
        [this.idsucursal, this.nombresucursal, this.ciudadsucursal, this.activos, this.region]
      );
      
      console.log("Sucursal creada");
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
        'UPDATE sucursal SET nombresucursal = :nombresucursal, ciudadsucursal = :ciudadsucursal, activos = :activos, region = :region WHERE idsucursal = :idsucursal',
        [this.nombresucursal, this.ciudadsucursal, this.activos, this.region, this.idsucursal]
      );
        */
      const result = await conn.execute(
        'BEGIN ActualizarSucursal(:idsucursal,:nombresucursal,:ciudadsucursal,:activos,:region); END;',
        [this.idsucursal,this.nombresucursal, this.ciudadsucursal, this.activos, this.region]

      );
      console.log("Sucursal actualizada");
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
        'DELETE FROM sucursal WHERE idsucursal = :idsucursal',
        [this.idsucursal]
      );
    */
 
      const result = await conn.execute(
        'BEGIN BorrarSucursal(:idsucursal, :region); END;',
        [this.idsucursal, this.region]
      );

      console.log("Sucursal eliminada");
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

module.exports = Sucursal;

