# API Documentation: GitHub REST Integrations

The Bootstrap Tool interfaces directly with the GitHub REST API (v3) using standardized JSON payloads.

---

## Headers Required
Every API request incorporates the following headers:
- `Authorization: token <GITHUB_TOKEN>`
- `Accept: application/vnd.github.v3+json`
- `Content-Type: application/json`
- `User-Agent: Ironship-Roadmap-Bootstrap`

---

## API Endpoint Integration Matrix

### 1. Repository Verification
- **Endpoint**: `GET /repos/{owner}/{repo}`
- **Payload**: None
- **Responses**:
  - `200 OK`: Repository is valid.
  - `404 Not Found`: Repository is invalid.

### 2. Milestone Management
- **List Milestones**: `GET /repos/{owner}/{repo}/milestones?state=all`
- **Create Milestone**: `POST /repos/{owner}/{repo}/milestones`
  - Body: `{"title": "...", "description": "..."}`
- **Update Milestone**: `PATCH /repos/{owner}/{repo}/milestones/{number}`
  - Body: `{"title": "...", "description": "..."}`
- **Delete Milestone**: `DELETE /repos/{owner}/{repo}/milestones/{number}`

### 3. Label Management
- **List Labels**: `GET /repos/{owner}/{repo}/labels`
- **Create Label**: `POST /repos/{owner}/{repo}/labels`
  - Body: `{"name": "...", "color": "...", "description": "..."}`
- **Update Label**: `PATCH /repos/{owner}/{repo}/labels/{name}`
  - Body: `{"color": "...", "description": "..."}`
- **Delete Label**: `DELETE /repos/{owner}/{repo}/labels/{name}`

### 4. Issue Management
- **List Issues**: `GET /repos/{owner}/{repo}/issues?state=all&per_page=100`
- **Create Issue**: `POST /repos/{owner}/{repo}/issues`
  - Body:
    ```json
    {
      "title": "...",
      "body": "...",
      "milestone": 42,
      "labels": ["cli", "enhancement"]
    }
    ```
- **Close Issue**: `PATCH /repos/{owner}/{repo}/issues/{number}`
  - Body: `{"state": "closed"}`

---

## Exception Mapping

- **403/429 (Forbidden/Too Many Requests)**: Throws `RateLimitException`. The tool parses `retry-after` or computes delay via `x-ratelimit-reset` minus the current local timestamp.
- **500+ (Internal Server Errors)**: Throws `TransientException`, triggering a retry.
- **Other >= 400 (Client Errors)**: Throws standard `HttpException` and aborts.
