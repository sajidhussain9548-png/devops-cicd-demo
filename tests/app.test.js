const request = require("supertest");
const app = require("../src/app");

describe("App", () => {
  test("GET /health returns ok", async () => {
    const res = await request(app).get("/health");
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe("ok");
  });

  test("GET /api/info returns version details", async () => {
    const res = await request(app).get("/api/info");
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("version");
    expect(res.body).toHaveProperty("commit");
    expect(typeof res.body.uptimeSeconds).toBe("number");
  });

  test("GET / serves the status page", async () => {
    const res = await request(app).get("/");
    expect(res.statusCode).toBe(200);
    expect(res.text).toContain("Release status");
  });
});
