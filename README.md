# DiamondVM

DiamondVM is a lightweight virtual machine manager designed to work seamlessly with **Pterodactyl Panel**. This project provides a Docker-based environment that simplifies setup and deployment.

---

## Installation

1. **Download the Pterodactyl egg**:

   Download the `egg-diamondvm.json` file from this repository.

2. **Upload to Pterodactyl**:

   Go to your Pterodactyl Panel, navigate to the **Nests** section, and import the `egg-diamondvm.json` file.

3. **Create a Server**:

   After importing the egg, you can create a new server using the DiamondVM egg.

---

## Features

- Pre-configured Docker environment based on Debian Bookworm Slim.
- Includes essential tools: `bash`, `sshpass`, `rsync`, `tmux`, `screen`.
- Automatic installation of DiamondVM files via `install.sh`.
- Supports syncing shared folders between local and remote servers.

---

## Usage

Once your server is created with the DiamondVM egg:

- The server automatically runs the `install.sh` script on first start.
- The script ensures all files are in place and permissions are correctly set.
- DiamondVM starts automatically after installation.

---

## Contributing

Feel free to fork the repository and submit pull requests. Make sure any additions maintain compatibility with Pterodactyl.

---

## License

This project is licensed under the MIT License.
