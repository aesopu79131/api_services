This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## AWS Docker deployment

Deploy with **CodeBuild** (build Docker image, push to ECR) and **CodeDeploy** (run container on EC2).

### Prerequisites

- **ECR**: Create a repository (e.g. `dragon-live`) and note its URI.
- **CodeBuild**: Use a **Docker**-capable image (e.g. `aws/codebuild/standard:7.0`). In the build project, set environment variables:
  - `ECR_REPOSITORY_URI` = your ECR repo URI (e.g. `123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/dragon-live`)
  - Or set `AWS_REGION` and `IMAGE_REPO_NAME` (e.g. `dragon-live`) and ensure the build role can push to ECR.
- **EC2**: IAM instance profile must allow `ecr:GetAuthorizationToken` and `ecr:BatchGetImage` so the instance can pull the image.
- **CodeDeploy**: App and deployment group pointing at the same S3/artifact source as the CodeBuild output.

### Flow

1. CodeBuild runs `buildspec.yml`: builds the image, pushes to ECR, produces an artifact with `appspec.yml`, `scripts/`, and `image.txt`.
2. CodeDeploy deploys that artifact to EC2: copies to `/opt/dragon-live`, runs `BeforeInstall` (install Docker), `ApplicationStop` (stop container), `ApplicationStart` (ECR login, pull, `docker run`).
3. App listens on port **3000** inside the container. Set `HOST_PORT` (default 3000) or use a reverse proxy (e.g. nginx) in front if needed.

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
