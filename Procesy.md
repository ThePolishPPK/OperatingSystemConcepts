\title{Historia procesorów}
\author{Patryk 45118641800f7466ecce781cbda2de6f6d79eca9}
\date{5 Dec 2021}

\renewcommand*\contentsname{Spis treści}

\maketitle
\tableofcontents

\newpage

# Wstęp

W każdym systemie procesy muszą posiadać informacje o sobie, choćby po to, aby je identyfikować. Dane te mogą być przeznaczone do różnych celów.

W tej notatce przedstawione zostaną informacje, jakie może zawierać proces, metody tworzenia procesów, metody ich kolejkowania oraz komunikacja między nimi.

# Przeznaczenie procesu

Proces ma za zadanie agregować informacje o wykonywanym zadaniu. Identyfikuje się go poprzez numer Process ID (PID). W nowoczesnych systemach operacyjnych może wykonywać się więcej niż jeden proces „na raz”.

# Budowa procesu

Każdy proces jest opisywany przez **PCB** (Process Control Block), który jest strukturą danych. Blok **PCB** identyfikowany jest przez numer **PID** (Process Identificator), głównie po to aby móc powiązać proces z danymi które go opisują.

## Informacje zawarte w PCB

### Process state

Stan procesu na dany moment. Wyróżnia się stany takie jak:

- **New** Jest to początkowy stan, w którym proces został zdefiniowany, ale jego kod wykonywalny nie znajduje się w pamięci podstawowej tj. pamięć RAM.
    
- **Ready** W tym stanie kod procesu jest ładowany do pamięci podstawowej.
    
- **Waiting** Gdy kod znajduje się w pamięci podstawowej, system powinien przydzielić pamięć operacyjną (czyli miejsce na Stack, Heap oraz Data).
    
- **Executing** W tym stanie program jest wykonywany.
    
- **Terminated** Proces znajdujący się w tym stanie zakończył swoje działanie. Zwrócił on również sygnał wyjściowy.
    
- **Blocked** W tym stanie proces oczekuje na dokonanie operacji przez inne procesy oraz urządzenia lub zwolnienia zasobów np. zwolnienie pliku, który użytkuje inny proces, oczekiwanie na podłączenie skanera, oczekiwanie na dane od karty sieciowej.
    
- **Suspended** Jest to stan, w którym proces oczekuje na swoją kolejkę do wykonania.
    

### Program Counter

Adres kolejnej instrukcji, która powinna zostać wykonana.

### CPU Registers

Kopia rejestrów, jakie w danym momencie zawiera proces.

### CPU Scheduling Information

Informacje o priorytecie procesu, numerze planowanej kolejki oraz pointerem do niej.

### Accounting and Business Information

Ilość użytego czasu procesora.

### Memory-Management Information

Informacje o użytej pamięci, stronie pamięci, tablicy segmentów. *Większość elementów zależy od systemu pamięci zaimplementowanego w systemie operacyjnym.*

### I/O Status Information

Informacje o ilości odebranych/wysłanych danych. Blok zawiera również informację o otwartych plikach oraz urządzeniach IO.

## Struktura pamięci

Pamięć jest dzielona na segmenty, mogą one mieć różne uprawnienia tak jak pliki. Segmenty mogą służyć jednemu procesowi, jak i mogą być współdzielone tj. biblioteki systemowe.

### Uprawnienia segmentów pamięci

- **Read** \- *r* Proces możne odczytywać zawartość segmentu.
- **Write** \- *w* Proces może zapisywać/nadpisywać dane w segmencie.
- **Execute** \- *x* Proces może wykonywać kod umieszczony w tym segmencie.

### Oznaczenia segmentów

Segmenty oznacza się:

- *Nazwą pliku*, gdy ładowane dane pochodzą z zewnętrznego pliku. Podaje się również *inode* systemu pliku oraz *offset*, gdy plik zawiera więcej typów danych. Przykładowo, notatnik może posiadać wbudowane bitmapy czcionek.
- *Etykietą*, gdy proces korzysta z pustej pamięci jako HEAP, STACK, VVAR, VDSO itp. Etykietę oznacza się nawiasami kwadratowymi (schemat: \[*nazwa*\]), np: **\[heap\]**, **\[stack\]**, **\[vvar\]**.
- *Pustą wartością*, gdy proces w trakcie działania dokona lokacji pamięci.

# Multi-processing

Aby udzielić procesom równego dostępu do zasobów, korzysta się z kolejkowania zadań. Gdy zadanie nie zostanie wykonane w trakcie określonego czasu, trafia na koniec kolejki. W trakcie procesu kolejkowania dochodzi do przełączenia się między procesami, operacja ta nazywa się **Context Switch**.

## Kolejkowanie procesów

Procesy mogą znaleźć się w różnych kolejkach, zależy to głównie od zasobu, jaki na dany moment potrzebują.

### Typy kolejek

- **Ready queue** – Kolejka dostępu do procesora, podczas jego wykonywania proces może przejść do innych kolejek.
- **I/O queue** – Kolejka dostępu do urządzenia I/O. Proces oczekuje w niej na zwolnienie dostępu do pliku lub fizycznego urządzenia I/O.
- **Fork child queue** – Proces oczekuje w niej na stworzenie podprocesu oraz na jego ewentualne zakończenie.
- **Interrupt queue** – Proces oczekuje na otrzymanie dowolnego przerwania.

### Rodzaje kolejek

Powszechnie wyróżnia się dwa rodzaje kolejek **short-term** oraz **long-term**.

#### Short-term

Nazywana również *CPU scheduler*. W takiej kolejce dane znajdują się w pamięci operacyjnej i są gotowe do wykonania. Proporcja czasu kolejkowania do odświeżania musi być optymalna. Jeśli kolejkowanie zajmuje 10ms a odświeżanie 100ms, procesor traci 10ms, czyli 10ms / (100ms + 10ms) = 9% swojego czasu pracy.

#### Long-term

Nazywany również *Job scheduler*. Jego czas odświeżania nie jest ściśle określony przez interwał, a poprzez zwolnienie się wymaganych zasobów systemowych. Procesy znajdujące się w tej kolejce nie znajdują się w pamięci operacyjnej, a np. na dysku.

#### Medium-term

Taka kolejka nie jest zbyt popularna, gdyż wykorzystywana jest do **swapping**’u. Poprzez co jest bardzo podobna do **Long-term scheduler**, ale różni się czynnikiem aktywującym proces przywrócenia procesu z pamięci operacyjnej. Mianowicie jest on aktywowany według czasu spędzonego na wykonywaniu. Aby zapewnić równomierność czasu dostępu do pamięci, stosuje się właśnie tą kolejkę.

## Context Switch

Proces polega na wykonaniu kopii rejestrów procesora aktualnie wykonywanego procesu oraz nadpisanie ich rejestrami kolejnego. W trakcie takiej operacji zmieniany jest również wirtualna pamięć i *Program Counter* co powoduje rozpoczęcie wykonywania się procesu, który był w kolejce.

# Operacje na procesach

## Tworzenie procesów

Procesy identyfikowane są poprzez numer PID (Process Identificator). W systemach ułożone są według hierarchii, co daje możliwość izolacji procesów, które nie powinny mieć wpływu na swoje działanie.

### Standard POSIX (w tym: Linux, Darwin, BSD)

W systemach implementujących standard POSIX, tworzenie nowego procesu polega na duplikowaniu poprzedniego wraz z *Program Counter*’em. Doprowadza to do utworzenia dwóch takich samych procesów różniących się wartością zwróconą przez `fork();`. Do tworzenia procesów wykorzystuje się funkcję `pid_t fork(void);`. Zwraca ona wartość:

- Ujemną, gdy wystąpił błąd.
- Nie zerową, gdy udało się utworzyć proces.
    - Gdy zwrócona wartość równa 0, oznacza, iż aktualnie wykonywany proces jest nowym procesem.
    - Gdy większe od 0 oznacza, iż aktualny proces jest procesem głównym, a wartość jest numerem PID utworzonego podprocesu.

Przykładowe użycie funkcji `fork();`.

```c
/* Biblioteki zgodne ze standardem POSIX */
#include <unistd.h>
#include <sys/types.h>

int main() {
    pid_t new_pid = fork();
    
    if (new_pid < 0) {
        // Kod wykonany gdy powstały błędy		
    } else if (new_pid == 0) {
        // Kod wykonany w nowym procesie
    } else { // new_pid > 0
        // Kod wykonany w pierwotnym procesie
    }
}
```

W celu uruchomienia innego programu wykonywalnego dla nowego procesu należy sprawdzić, czy zwrócona wartość z `fork()` równa 0 (oznacza, iż aktualny proces jest nowym). Po sprawdzeniu wartości wykonuje się jedną z dostępnych funkcji:

```c
int execl(const char *pathname, const char *arg, ...
         /* (char  *) NULL */);
int execlp(const char *file, const char *arg, ...
         /* (char  *) NULL */);
int execle(const char *pathname, const char *arg, ...
         /*, (char *) NULL, char *const envp[] */);
int execv(const char *pathname, char *const argv[]);
int execvp(const char *file, char *const argv[]);
int execvpe(const char *file, char *const argv[],
            char *const envp[]);
```

Gdy zapisze się nazwę funkcji jako schemat **exec**\[etykiety\] to etykiety oznaczają odpowiednio:

- **l** Argumenty dla procesu, podawane są po przecinku przy wywoływaniu funkcji. Ostatni argument musi być *NULL*’em.
- **v** Argumenty dla procesu, podawane są jako wskaźnik na listę.
- **e** Uruchamiany proces przyjmuje zmienne środowiskowe jako wskaźnik na listę **envp**. W przypadku używania **l** należny argumenty zakończyć NULL pointerem, a następnie podać wskaźnik na listę zmiennych środowiskowych.
- **p** Wyszukuje pliku wykonywalnego, używając ścieżek zdefiniowanych w zmiennych środowiskowych. Pozwala to na oszczędzenie czasu w odnalezieniu plików wykonywalnych, przeznaczonych dla konsoli.

Niektóre systemy operacyjne posiadają usprawnienie, jakim jest `pid_t vfork(void);`. Przy użyciu tego polecenia ignorowane jest kopiowanie tabel pamięci, co oszczędza zasoby. Przydatne, gdy wykonywana jest któraś z funkcji **exec** jest wykonywana po utworzeniu procesu.

### Windows

Aby utworzyć nowy podproces, należy w pierwszej kolejności utworzyć struktury *STARTUPINFO* oraz *PROCESS_INFORMATION*. Wykonanie funkcji `CreateProcess` powoduje uruchomienie nowego procesu z wykorzystaniem polecenia podanego jako argument.

Przykład otwierania Painta w systemie Windows:

```c
#include <stdio.h>
#include <windows.h>

int main(void) {
    STARTUPINFO si;
    PROCESS_INFORMATION pi;
    /* Alokuje pamięć */
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    ZeroMemory(&pi, sizeof(pi));
    
    /* Tworzy nowy proces */
    if (!CreateProcess(NULL,
        "C:\\WINDOWS\\system32\\mspaint.exe", /* Polecenie do wykonania */
        NULL,
        NULL,
        FALSE,
        0,
        NULL,
        NULL,
        &si,
        &pi))	{
        fprintf(stderr, "Nie można utworzyć procesu!");
        return -1;
    }
    /* Oczekuj do zkończenia działania nowego procesu */
    WaitForSingleObject(pi.hProcess, INFINITE);
    printf("Child Complete");
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
}
```

# Interprocess Communication

Procesy w systemach operacyjnych mogą pracować niezależnie od innych lub współpracować z innymi procesami. Współpraca taka polega na wymianie danych między procesami. Fundamentalnymi metodami wymiany informacji, są:

- **Shared memory** (Współdzielona pamięć) Metoda polega na współdzieleniu segmentu pamięci, w którym jeden proces zapisuje dane, a drugi odczytuje.
- **Message passing** (Przekazywanie wiadomości) Metoda polega na udostępnieniu przez kernel specjalnego API, z którego użyciem przekazywane są dane do procesu. Pojęcie to jest uniwersalne, gdyż umożliwia komunikację między procesami niebędącymi w jednym systemie np. poprzez sieć.

## Cele wymiany danych

- **Wymiana informacjami** Pozwala na zaoszczędzenie mocy obliczeniowej lub pamięci, gdy przynajmniej dwa procesy używają tych samych danych np. bibliotek.
- **Przyśpieszenie operacji** Poprzez utworzenie większej ilości procesów zwiększamy ilość zasobów, jakie zostały do niego przydzielone.
- **Modularność** Dobrze zaprojektowana aplikacja powinna dzielić logicznie swoje operacje na mniejsze części. Przykładem jest przeglądarka, wykorzystuje ona osobne procesy do renderowania strony, obsługi skryptów oraz wtyczek.

## Metody wymiany danych

### Systemy Shared Memory

Podczas wymiany danych w takim systemie, dochodzi do podziału na nadawce i odbiorce. Można to przyrównać do klienta i serwera, choć w tym przypadku nazywa się te role Producer (Nadawca) i Consumer (Odbiorca). Aby nadawca mógł nadać dane, należy w pierwszej kolejności uzgodnić wspólny schemat wiadomości oraz współdzielić pamięć.

Standard POSIX udostępnia funkcje dla współdzielenia pamięci. Są to:

```c
int shm_open(const char *name, int oflag, mode_t mode);
int shm_unlink(const char *name);
int ftruncate(int fd, off_t length);
void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);
```

Aby utworzyć nowy obiekt pamięci współdzielonej, należy wywołać [`shm_open`](https://man7.org/linux/man-pages/man3/shm_open.3.html) z flagą `O_CREAT`.

```c
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>

int id = shm_open('Dowolna nazwa', O_RDWR | O_CREAT, S_IRWXU | S_IROTH);
```

Tak utworzona pamięć nie posiada określonego rozmiaru. Należy go ustalić poprzez wyczyszczenie regionu pamięci z użyciem [`ftrunacate`](https://www.man7.org/linux/man-pages/man3/ftruncate.3p.html):

```c
#include <unistd.h>

ftruncate(id, 4096);
```

Obiekt nie został jeszcze mapowany na pamięć wirtualną. Aby tego dokonać, należy użyć [`mmap`](https://www.man7.org/linux/man-pages/man2/mmap.2.html):

```c
#include <sys/mman.h>

void* ptr = mmap(NULL, 4096, PROT_READ, MAP_SHARED, id, 0);
```

Przykładowy program komunikujący się z użyciem współdzielonej pamięci: [producer.c](:/c68f5a1ac361490b9002af0a89cf794c) [consumer.c](:/12241370a7fb4fa48f971de8e2c9a57e) [compile.sh](:/7bb849bca08a4d5f9c236160fce9ada2)

### Message Passing

W takim systemie wymiany danych nadawcą i odbiorcą może ten sam proces. Podczas łączenia więcej niż dwóch procesów należy zauważyć, iż dane odczytane raz znikają z kolejki. A dodatkowo jest to system jednokierunkowy.

Systemy implementujące POSIX, posiadają funkcje:

```c
#include <mqueue.h>

mqd_t mq_open(const char *name, int oflag);
mqd_t mq_open(const char *name, int oflag, mode_t mode, struct mq_attr *attr);

int mq_send(mqd_t mqdes, const char *msg_ptr, size_t msg_len, unsigned int msg_prio);
int mq_timedsend(mqd_t mqdes, const char *msg_ptr, size_t msg_len, unsigned int msg_prio, const struct timespec *abs_timeout);

ssize_t mq_receive(mqd_t mqdes, char *msg_ptr, size_t msg_len, unsigned int *msg_prio);
ssize_t mq_timedreceive(mqd_t mqdes, char *msg_ptr, size_t msg_len, unsigned int *msg_prio, const struct timespec *abs_timeout);

int mq_unlink(const char *name);
```

Aby procesy mogły się komunikować, należy utworzyć kolejkę, z której będą odczytywać i zapisywać dane. Służy do tego funkcja [`mq_open`](https://man7.org/linux/man-pages/man3/mq_open.3.html):

```c
#include <fcntl.h>
#include <mqueue.h>

// W przypadku gdy kolejka może nie istnieć.
mqd_t mq_dec = mq_open("/NazwaKolejki", O_RDWR | O_CREAT, 0644, NULL);

// Gdy kolejka napewno istnieje.
mqd_t mq_dec = mq_open("/NazwaKolejki", O_RDWR);
```

Ustawienie wskaźnika atrybutów na NULL powoduje użycie domyślnych ustawień.

Gdy zdefiniowane zostały kolejki, można nadać wiadomość/dane z funkcją [`mq_send`](https://man7.org/linux/man-pages/man3/mq_send.3.html):

```c
#include <mqueue.h>

mq_send(mq_dec, "Wiadomość :)", 14, 0);
```

Odbieranie danych odbywa się z użyciem funkcji [`mq_receive`](https://man7.org/linux/man-pages/man3/mq_receive.3.html):

```c
#include <mqueue.h>

char buffer[1024];
mq_receive(mq_dec, buffer, 1024, 0);
```

Gdy dane już nie będą wymieniane, należy zakończyć połączenie funkcją [`mq_unlink`](https://man7.org/linux/man-pages/man3/mq_unlink.3.html):

```c
#include <mqueue.h>

mq_unlink("/NazwaKolejki");
```

### Sockets

Jest to odmiana Message Passing obsługująca głównie sieć. Aby procesy dwa mogły się komunikować, muszą posiadać swoje *socket*’y (gniazda). Komunikacja bazuje na architekturze klient-serwer, jeden proces nasłuchuje na swoim socket’cie do momentu uzyskania połączenia.

Socket tworzy się z pomocą funkcji [`socket`](https://www.man7.org/linux/man-pages/man2/socket.2.html);

```c
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

int desc = socket(AF_INET, SOCK_STREAM, getprotobyname("IP")->p_proto);
```

Socket musi być identyfikowany przez pewne dane. Dla komunikacji *INET* jest to adres IPv4 oraz port. Strukturę takich danych należy przypisać do socket’u z pomocą funkcji [`bind`](https://www.man7.org/linux/man-pages/man2/bind.2.html):

```c
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>

struct sockaddr_in address = {
    .sin_family = AF_INET,
    .sin_port = (in_port_t) htons(80),
    .sin_addr = (struct in_addr) {
        .s_addr = 0
    }
};

bind(desc, (const struct sockaddr*) &address, sizeof(address));
```

Architektura klient serwer nie gwarantuje natychmiastowego połączenia się procesów. Serwer znajduje się w stanie nasłuchiwania portu na przychodzące połączenia. Aby wstrzymać wykonywanie programu do momentu nawiązania połączenia, wykorzystuje się funkcję [`listen`](https://www.man7.org/linux/man-pages/man2/listen.2.html):

```c
#include <sys/types.h>
#include <sys/socket.h>

listen(desc, 1);
```

Gdy udało się nawiązać połączenie z procesem, należy uzyskać jego adres do odpowiedzi. Akceptowanie połączenia dokonuje się z funkcją [`accept`](https://www.man7.org/linux/man-pages/man2/accept.2.html):

```c
#include <sys/types.h>
#include <sys/socket.h>

struct sockaddr client_addr;
socklen_t client_socklen;

int client_desc = accept(desc, &client_addr, &client_socklen);
```

Posiadając już najważniejsze dane, można rozpocząć komunikację z pomocą funkcji [`read`](https://man7.org/linux/man-pages/man2/read.2.html) oraz [`send`](https://www.man7.org/linux/man-pages/man2/send.2.html):

```c
#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include <unistd.h>

char buffer[1024];
ssize_t msg_recv_len, msg_send_len;
msg_recv_len = read(client_desc, &buffer, sizeof(buffer));

memset(&buffer, 0, sizeof(buffer));
memcpy(&buffer, "Wiadomość :)", 14);
send(client_desc, &buffer, sizeof(buffer), 0);
```

Klient, który ma połączyć się z serwerem, nie musi określać swojego portu, gdyż system zrobi to sam. Aby móc się komunikować z serwerem, należy utworzyć socket oraz użyć funkcji [`connect`](https://man7.org/linux/man-pages/man2/connect.2.html):

```c
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>

uint32_t addr;
inet_pton(AF_INET, "127.0.0.1", &addr);

struct sockaddr_in server_addr = {
    .sin_family = AF_INET,
    .sin_port = (in_port_t) htons(80),
    .sin_addr = (struct in_addr) {
        .s_addr = addr
    }
};

int desc = socket(AF_INET, SOCK_STREAM, getprotobyname("IP")->p_proto);
connect(desc, (const struct sockaddr*) &server_addr, sizeof(server_addr));
```

### Pipes

Pipes to bezkierunkowa kolejka FIFO, w której dane są umieszczane na początku kolejki (write\_end) a odbierane na jej końcu (read\_end). W systemach implementujących POSIX do tworzenia takiego połączenia używa się funkcji [`pipe`](https://man7.org/linux/man-pages/man2/pipe.2.html):

```c
#include <unistd.h>

int pipefd[2];
int pipe(pipefd);
```

Podana zmienna jako `pipefd` będzie zawiereać identyfikatory służące do komunikacji. Aby móc prowadzić komunikacje należy utworzć nowy proces poprzez użycie funkcji `fork`, gdyż klonuje ona również otwarte pliki jakim w tym przypadku jest plik kolejki FIFO.

```c
#include <unistd.h>

fork();
```

Aby dane mogły swobodnie przepływać, należy ustalić *File Descriptor* który będzie pełnił funkcję *read_end* a który *write_end*. Zgodnie z dokumentacją Linux’a przyjmuje się, że pierwszy *File Descriptor* jest *read_end*’em. Gdy ustalone są już *File Descriptor*’y można rozpocząć komunikacje, używając standardowych funkcji [`read`](https://man7.org/linux/man-pages/man2/read.2.html) oraz [`write`](https://man7.org/linux/man-pages/man2/write.2.html).

Przykład komunikacji z użyciem `pipe`:

```c
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
    int fd[2];
    if (pipe(fd) == -1) {
        printf("Pipe open error: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    pid_t pid = fork();
    if (pid == -1) {
        printf("Fork error: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    } else if (pid == 0) {
        close(fd[0]);	// Ten proces nie odczytuje danych
        write(fd[1], "Wiadomość :)", 14);
        close(fd[1]);	// Dane już nie będą wysyłane
        exit(EXIT_SUCCESS);
    }
    close(fd[1]);	// Ten proces nie zapisuje danych
    char buffer[32];	// 32-bajtowy bufer
    if (read(fd[0], &buffer, sizeof(buffer)) == -1) {
        printf("Read error: %s\n", strerror(errno));
        close(fd[0]);
        exit(EXIT_FAILURE);
    }
    printf("Otrzymane dane: %s\n", buffer);
    close(fd[0]);
    exit(EXIT_SUCCESS);
}
```

# Bibliografia

---
notice: |
	@Silberschatz2006
...