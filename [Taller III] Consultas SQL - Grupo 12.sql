--Ejercicio 1
--Mostrar la lista de clientes que han contratado el plan "Premium". Ordenar el resultado con respecto al
--id del cliente en orden ascendente. Almacenar el resultado en una nueva tabla llamada "CLIENTES_PREMIUM”.

SELECT 
    c.nombre 'Cliente', c.direccion 'Direccion', tp.tipo 'Tiplo de plan' 
INTO CLIENTES_PREMIUM
FROM CLIENTE c
INNER JOIN TIPO_PLAN tp
    ON c.id_tipo_plan = tp.id
WHERE 
    tp.tipo = 'Premium'
ORDER BY 
    c.id ASC;

--Ejercicio 2
--Mostrar las 2 clínicas más populares. El parámetro de popularidad se define en base al número de
--citas registradas por cada clínica. Mostrar el id de la clínica, el nombre, su dirección y email, además
--mostrar la cantidad de citas registradas. Ordenar el resultado en base a la cantidad de citas
--registradas

SELECT TOP 2
    cl.id, cl.nombre 'Clinida', cl.direccion 'Direccion', cl.email 'Email', COUNT(ct.id) '# de citas'
FROM CLINICA cl
INNER JOIN CITA ct
    on cl.id = ct.id_clinica
GROUP BY
    cl.id, cl.nombre, cl.direccion, cl.email
ORDER BY
    COUNT(ct.id) DESC;

--Ejercicio 3
--Mostrar la información completa de cada cliente, incluir el nombre, dirección, el tipo de plan, los
--correos (si es que ha brindado alguno) y los teléfonos (si es que ha brindado alguno). Ordenar el
--resultado con respecto al id del cliente en orden ascendente.

SELECT
    c.id, c.nombre, c.direccion, cc.correo, tc.telefono
FROM CLIENTE c
LEFT JOIN CORREO_CLIENTE cc
    ON c.id = cc.id_cliente
LEFT JOIN TELEFONO_CLIENTE tc
    ON c.id = tc.id_cliente
ORDER BY
    c.id ASC;

--Ejercicio 4
--Identificar las consultas que han necesitado de un médico asistente, mostrar el id de la consulta, la
--fecha, la duración, el id del médico y el nombre del médico asistente. Ordenar el resultado con
--respecto al id de la consulta en orden ascendente.

SELECT 
    c.id '# de consulta', c.fecha 'Fecha de realizacion', c.duracion 'Duracion de la consulta',
    m.id, m.nombre 'Nombre del medico asistente'
FROM CONSULTA c
INNER JOIN MEDICOXCONSULTA mc
    ON mc.id_consulta = c.id
INNER JOIN MEDICO m
    ON mc.id_medico = m.id
WHERE mc.rol = 0
ORDER BY
    c.id ASC;

--Ejercicio 5
--¿Cuáles son las clínicas capacitadas para atender emergencias? Mostrar el id de la clínica, el nombre,
--la dirección y email.

SELECT
    cl.id, cl.nombre 'Clinica', cl.direccion, cl.email
FROM CLINICA cl
INNER JOIN EMERGENCIA em
    ON em.id_clinica = cl.id
GROUP BY
    cl.id, cl.nombre, cl.direccion, cl.email;

--Ejercicio 6
--Calcular las ganancias de la asociación en la primera quincena de mayo. Mostrar la fecha de la
--consulta, el nombre del cliente atendido y el nombre del médico principal. Se debe considerar que
--existe la posibilidad de que haya consultas en las que no se recete ningún medicamento. Ordenar el
--resultado con respecto al id de la consulta en orden ascendente. Las ganancias de cada consulta se
--calculan de la siguiente forma: (Precio de la consulta + Suma de todos los medicamentos recetados) +
--13% IVA.

SELECT 
    c.id, c.fecha 'Fecha realizacion', cl.nombre 'Cliente', m.nombre 'Medico principal', ((c.precio + ISNULL(SUM(md.precio),0))*1.13) 'Ganancias por consulta'
FROM CONSULTA c
INNER JOIN CLIENTE cl
    ON c.id_cliente = cl.id
INNER JOIN MEDICOXCONSULTA mc
    ON mc.id_consulta = c.id
INNER JOIN MEDICO m
    ON mc.id_medico = m.id
LEFT JOIN RECETA r
    ON r.id_consulta = c.id
LEFT JOIN MEDICAMENTO md
    ON r.id_medicamento = md.id
WHERE mc.rol = 1
GROUP BY
    c.id, c.fecha, cl.nombre, m.nombre, c.precio
HAVING c.fecha BETWEEN '2022-05-01' AND '2022-05-15'
ORDER BY 
    c.id ASC;

--Ejercicio 7
--El comité de dirección planea realizar una fuerte inversión con el objetivo de establecer a la asociación
--como el consorcio líder a nivel nacional, para verificar la viabilidad del proyecto, el comité ha solicitado
--un reporte especial que consiste en mostrar las ganancias del mes de mayo de 2022 pero
--organizadas en base a 4 grupos de fechas. Por acuerdo del comité, los 4 grupos son los siguientes:

WITH tmp AS
(
    SELECT
        CASE
            WHEN c.fecha BETWEEN '2022-05-01' AND '2022-05-08' THEN ((c.precio + ISNULL(SUM(md.precio),0))*1.13)
        END AS UNO,
        CASE
            WHEN c.fecha BETWEEN '2022-05-08' AND '2022-05-15' THEN ((c.precio + ISNULL(SUM(md.precio),0))*1.13)
        END AS DOS,
        CASE
            WHEN c.fecha BETWEEN '2022-05-15' AND '2022-05-22' THEN ((c.precio + ISNULL(SUM(md.precio),0))*1.13)
        END AS TRES,
        CASE
            WHEN c.fecha BETWEEN '2022-05-22' AND '2022-05-31' THEN ((c.precio + ISNULL(SUM(md.precio),0))*1.13)
        END AS CUATRO
    FROM CONSULTA c
    INNER JOIN CLIENTE cl
        ON c.id_cliente = cl.id
    INNER JOIN MEDICOXCONSULTA mc
        ON mc.id_consulta = c.id
    INNER JOIN MEDICO m
        ON mc.id_medico = m.id
    LEFT JOIN RECETA r
        ON r.id_consulta = c.id
    LEFT JOIN MEDICAMENTO md
        ON r.id_medicamento = md.id        
    GROUP BY
        c.id, c.fecha, cl.nombre, m.nombre, c.precio
)

SELECT 
    SUM(UNO) AS 'Semana 1', SUM(DOS) AS 'Semana 2', SUM(TRES) AS 'Semana 3', SUM(CUATRO) AS 'Semana 4'
FROM tmp;