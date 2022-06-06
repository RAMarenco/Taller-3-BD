--Moises Ezequiel Juárez Mejía 00038221 
--Roberto Andrés Marenco Rivas 00080121
--Rafael Andrés Quezada Azenon 00084021 

--Ejercicio 1
--Mostrar la lista de clientes que han contratado el plan "Premium". Ordenar el resultado con respecto al
--id del cliente en orden ascendente. Almacenar el resultado en una nueva tabla llamada "CLIENTES_PREMIUM”.

SELECT 
    c.id, c.nombre, c.direccion, tp.tipo
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
    cl.id, cl.nombre, cl.direccion, cl.email, COUNT(ct.id) 'citas_registradas'
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
    c.id, c.nombre, c.direccion, tp.tipo, tc.telefono, cc.correo
FROM CLIENTE c
INNER JOIN TIPO_PLAN tp
    ON c.id_tipo_plan = tp.id
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
    c.id 'id_consulta', c.fecha, c.duracion,
    m.id 'id_médico', m.nombre 'médico_asistente'
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
    cl.id, cl.nombre, cl.direccion, cl.email
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
    c.id 'id_consulta', c.fecha, cl.nombre 'nombre_cliente', m.nombre 'nombre_medico', ISNULL(SUM(md.precio),0) 'subtotal_medicamento', c.precio 'precio_consulta', CAST((c.precio + ISNULL(SUM(md.precio),0))*1.13 AS DECIMAL(10,2)) 'total_consulta'
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
            WHEN CONVERT(DATE,c.fecha) BETWEEN '2022-05-01' AND '2022-05-08' THEN 'Semana 1'
            WHEN CONVERT(DATE,c.fecha) BETWEEN '2022-05-09' AND '2022-05-15' THEN 'Semana 2'
            WHEN CONVERT(DATE,c.fecha) BETWEEN '2022-05-16' AND '2022-05-22' THEN 'Semana 3'
            WHEN CONVERT(DATE,c.fecha) BETWEEN '2022-05-23' AND '2022-05-31' THEN 'Semana 4'
        END AS semana,
        CASE
            WHEN CONVERT(DATE,c.fecha) BETWEEN '2022-05-01' AND '2022-05-08' THEN CAST((c.precio + ISNULL(SUM(md.precio),0))*1.13 AS DECIMAL(10,2))
            WHEN CONVERT(DATE,c.fecha) BETWEEN '2022-05-09' AND '2022-05-15' THEN CAST((c.precio + ISNULL(SUM(md.precio),0))*1.13 AS DECIMAL(10,2))
            WHEN CONVERT(DATE,c.fecha) BETWEEN '2022-05-16' AND '2022-05-22' THEN CAST((c.precio + ISNULL(SUM(md.precio),0))*1.13 AS DECIMAL(10,2))
            WHEN CONVERT(DATE,c.fecha) BETWEEN '2022-05-23' AND '2022-05-31' THEN CAST((c.precio + ISNULL(SUM(md.precio),0))*1.13 AS DECIMAL(10,2))
        END AS Ganancia
    FROM CONSULTA c
    INNER JOIN CLIENTE cl
        ON c.id_cliente = cl.id
    LEFT JOIN RECETA r
        ON r.id_consulta = c.id
    LEFT JOIN MEDICAMENTO md
        ON r.id_medicamento = md.id
    GROUP BY
        c.id, c.fecha, cl.nombre, c.precio
)

SELECT 
    semana, SUM(Ganancia) 'ganancia_semanal'
FROM tmp
GROUP BY semana;