import express from "express"
import jwt from "jsonwebtoken"
import fetch from "node-fetch"

const app = express()
const port = 3000

// Set CORS configuration to authorize all origins
app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*")
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization")
    next()
})

// Middleware pour vérifier le token
const verifyToken = async (req, res, next) => {
    const bearerHeader = req.headers["authorization"]
    if (typeof bearerHeader !== "undefined") {
        const bearer = bearerHeader.split(" ")
        const bearerToken = bearer[1]
        req.token = bearerToken

        try {
            // Récupérer la clé publique de Keycloak
            const response = await fetch("http://keycloak:8080/realms/mocked-responses/protocol/openid-connect/certs")
            const jwks = await response.json()

            let publicKey = ""

            jwks.keys.forEach((key) => {
                if (key.alg === "RS256") {
                    console.log(`X5C count : ${key.x5c.length}`)
                    key.x5c.forEach((x5c) => {
                        console.log(`X5C : ${x5c}`)
                    })
                    publicKey = key.x5c[0]
                }
            })

            // Vérifier le token
            const verified = await jwt.verify(bearerToken, `-----BEGIN CERTIFICATE-----\n${publicKey}\n-----END CERTIFICATE-----`, {
                algorithms: ["RS256"],
            })
            if (!verified) {
                console.error("Token not verified")
                res.sendStatus(403)
            }

            const decoded = jwt.decode(bearerToken)
            console.log("Token verified")
            console.log(decoded)
            req.user = decoded

            next()
        } catch (err) {
            console.error(err)
            res.sendStatus(403)
        }
    } else {
        console.error("Token not provided")
        res.sendStatus(403)
    }
}

app.get("/api/user", verifyToken, (req, res) => {
    res.json({
        name: req.user.name,
        email: req.user.email,
    })
})

app.listen(port, () => {
    console.log(`API running on port ${port}`)
})
