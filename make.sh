if ! command -v pandoc &> /dev/null; then
	echo "PANDOC command missing in system!"
	exit 1
else
	documents=("Procesy" "Wątki" "Synchronizacja procesów" "Kolejkowanie przez procesor" "Deadlock" "Pamięć Operacyjna" "Historia procesorów" "Pamięć Wirtualna")
	
	for document in "${documents[@]}"; do
		if [ -r "$document.md" ]; then
			echo "Processing: $document.md"
			pandoc --bibliography=Resources/Bibliography.bib \
				--highlight-style=kate \
				-t pdf \
				-f markdown \
				-V 'mainfont:DejaVuSerif.ttf' \
				--pdf-engine=xelatex \
				-V geometry:margin=1in \
				"$document.md" > "$document.pdf"
			echo "File saved as: $document.pdf"
		else
			echo "Cannot found or read file: $document.md"
			exit 1
		fi
	done
fi