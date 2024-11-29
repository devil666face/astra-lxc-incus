package fs

import (
	"embed"
	"fmt"
	"io"
	"os"
	"path/filepath"

	"github.com/google/uuid"
)

func WriteFile(path string, data []byte) error {
	if err := os.WriteFile(path, data, 0777); err != nil {
		return fmt.Errorf("failed to save file: %w", err)
	}
	return nil
}

func TempPath(suffix ...string) string {
	if len(suffix) > 0 {
		return filepath.Join("/", "tmp", uuid.NewString()+suffix[0])
	}
	return filepath.Join("/", "tmp", uuid.NewString())
}

func FileExists(filename string) bool {
	if _, err := os.Stat(filename); err == nil {
		return true
	} else {
		if os.IsNotExist(err) {
			return false
		}
	}
	return false
}

func EmbedToFS(dest string, fs embed.FS) ([]string, error) {
	if err := os.MkdirAll(dest, os.ModePerm); err != nil {
		return nil, fmt.Errorf("destination create folder error: %w", err)
	}
	return saveEmbedFiles(fs, dest)
}

func saveEmbedFiles(fs embed.FS, dest string) ([]string, error) {
	var (
		root  = filepath.Base(dest)
		saved = []string{}
	)

	entries, err := fs.ReadDir(root)
	if err != nil {
		return nil, err
	}

	for _, entry := range entries {
		if !entry.IsDir() {
			var destfile = filepath.Join(dest, entry.Name())

			if err := embedToFS(
				fs,
				filepath.Join(root, entry.Name()),
				destfile,
			); err != nil {
				return nil, err
			}
			saved = append(saved, destfile)
		}
	}
	return saved, nil
}

func embedToFS(fs embed.FS, src string, dest string) error {
	file, err := fs.Open(src)
	if err != nil {
		return err
	}
	defer file.Close()

	out, err := os.Create(dest)
	if err != nil {
		return err
	}
	defer out.Close()

	_, err = io.Copy(out, file)
	return err
}
