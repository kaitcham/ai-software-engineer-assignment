FROM node:20-slim

WORKDIR /app

# Copy only the package file first to leverage Docker cache
COPY package.json ./

# Install exact versions defined in package.json
RUN npm install

# Copy the rest of the application
COPY . .

# Run tests in a non-interactive CI-style environment
CMD ["npm", "test"]
