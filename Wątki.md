\title{Historia procesorów}
\author{Patryk 45118641800f7466ecce781cbda2de6f6d79eca9}
\date{13 Dec 2021}

\renewcommand*\contentsname{Spis treści}

\maketitle
\tableofcontents

\newpage

# Wstęp

Wątek to najmniejsza logiczna część procesu. Umożliwiają one wykonywanie obliczeń nie zależnie od siebie.

W tej notatce zostanie przedstawiona budowa wątku, sposób jego obsługi w systemie oraz cechy niektórych wątków.

# Budowa wątku

Wątek się on z identyfikatora, *Program Counter*’a, rejestrów oraz stosu. Pozostałe dane są współdzielone z innymi wątkami należącymi do tego samego procesu.

Proces posiadający tylko jeden wątek, nazywany jest procesem *jednowątkowym*(single-thread). Natomiast proces posiadający przynajmniej dwa wątki, nazywany jest *wielowątkowym*(multi-thread). Ułatwia on wykonywanie operacji niezależnych od siebie. Przykładowo jeden wątek w edytorze tekstu może odpowiadać za wyświetlanie, a drugi za formatowanie teksu. Wadą multi-threadingu jest wymóg wprowadzenia blokad dostępu do zasobów, często nazywa się je semaforami.

## Zalety wielowątkowości

- **Responsywność** Pozwala na wykonywanie wielu operacji, nawet gdy są wymagające obliczeniowo. Przykładowo program graficzny dla użytkownika może na jednym wątku wykonywać długotrwałe obliczenia, a na drugim obsługiwać interfejs użytkownika. Przy wykorzystaniu procesu jedno wątkowego użytkownik zobaczyłby wynik kliknięcia przycisku po zakończeniu obliczeń.
- **Współdzielenie zasobów** Procesy w celu komunikacji między sobą muszą współdzielić pamięć (*Shared Memory*) lub używać *Message Passing*’u. Natomiast wątki zawsze współdzielą ze sobą przestrzeń adresową, co pozwala na korzystanie z tych samych zmiennych, do których można przesyłać dane.
- **Ekonomia** Wątki wykonujące obliczenia w obrębie jednego procesu współdzielą między sobą te same zasoby systemu operacyjnego. Oznacza to zmniejszenie ilości używanej pamięci oraz skrócenie czasu dostępu do innych zasobów takich jak plik.
- **Skalowalność** Wątki można wykonywać jednocześnie, ilość takich wątków jest zależna od ilości rdzeni procesora.

# Procesory wielordzeniowe

Początkowo w historii komputerów zwiększała się prędkość dokonywania obliczeń na jednym rdzeniu. Z czasem zaczęły dochodzić kolejne. Systemy operacyjne działające na procesorze wielordzeniowym nazywane są *wielordzeniowymi* (*multicore*) lub *wieloprocesorowymi* (*multiprocessor*).

System dokonuje obliczeń *równolegle* (*in parell*), gdy przynajmniej dwa wątki mogą być wykonywane jednocześnie. Natomiast gdy wątki są wykonywane w systemie jeden po drugim, to taki system nazywa się *współbieżnym* (*concurrency*).

## Prawo Amdahla

Prawo to pozwala określić maksymalny wzrost wydajność wykonania zadania, gdy określona została część zadania możliwa do wykonania wielowątkowo na określonej ilości rdzeni.

- S — Część zadania wykonywana szeregowo
- N — Ilość rdzeni

$$
wzrostWydajnosci \le \frac{1} { S + \frac{1-S}{N} } \newline
$$

## Wyzwania w programowaniu wielordzeniowym

- **Identyfikacja zadań** Idealnie rozdzielone zadania powinny być od siebie jak najbardziej niezależne (wymieniać jak najmniej danych). Przykładem takiego podziału zadań jest program synchronizujący dane z serwerem, jeden wątek sprawdza, czy dokonano zmiany w plikach, drugi natomiast wymienia dane z serwerem.
- **Balans** Zadania przydzielone do różnych wątków powinny mieć jak najbliższą sobie “wartość” pracy.
- **Podział danych** Wątki wykorzystujące te same dane powinny znajdować się na tym samym rdzeniu procesora, aby ograniczyć potrzebę ich kopiowania.
- **Zależność danych** Jedno zadanie może być zależne od danych z drugiego. Ważne jest, aby synchronizować wątki w celu zredukowania czasu oczekiwania na dane.
- **Testowanie** W systemach wielordzeniowych problematyczne staje się testowanie, kiedy to istnieje wiele wątków wykonywanych na raz.

## Rodzaje obliczeń równoległych

- **Równoległość danych** (*Data parallelism*) Polega na podzieleniu danych na podzbiory i rozdystrybuowaniu je na różne rdzenie. Takie rozłożenie danych pozwala na wykonywanie się takich samych obliczeń na zmniejszonym zbiorze danych.
- **Równoległość zadań** (*Task parallelism*) Zadania w tym przypadku powinny wykonywać unikalne operacje. Przykładem takiego procesu jest wcześniej wspomniany edytor tekstu.

# Modele wielowątkowości

Wątki w systemach operacyjnych mogą być uruchamiane na poziomie jądra systemowego (*kernel thread*) lub na poziomie użytkownika (*user thread*). Wątki jądra systemowego odgrywają rolę środowiska uruchomieniowego dla wątków użytkownika. Oznacza to, iż każdy proces użytkownika musi być mapowany na wątek jądra systemowego, poprzez co wyróżnia się następujące modele wielowątkowości:

#### Wiele do jednego (Many-to-One)

W tym modelu wątku użytkownika mapowane są na jeden wątek jądra. Jest to opcja najmniej optymalna, gdyż na raz może być wykonywany tylko jeden wątek.

#### Jeden do jednego (One-to-One)

W tym przypadku jeden wątek użytkownika mapowany jest na jeden wątek jądra systemowego. Rozwiązanie to pozwala na idealne rozdysponowanie czasu między wątkami oraz możliwość działania różnych wątków na różnych rdzeniach. Wadą tego rozwiązania jest wymóg utworzenia nowego wątku jądra systemowego, co wykorzystuje moc obliczeniową oraz pamięć.

#### Wiele do wielu (Many-to-Many)

W modelu tym wątki użytkowników mapowane są na tyle samo lub mniej wątków systemowych. Podobnie jak model “*jeden do jednego*” pozwala na wykonywanie wątków na wielu rdzeniach.

Dodatkowe wyjaśnienie różnicy między kernel a user thread oraz przyczyna istnienia mapowania user thread na kernel thread [tutaj](https://stackoverflow.com/questions/14791278/threads-why-must-all-user-threads-be-mapped-to-a-kernel-thread).

# Biblioteki do zarządzania wątkami

## POSIX

Systemy spełniające standard POSIX posiadają bibliotekę `Pthread`. Operacje, jakie będzie miał do wykonania wątek, zwarte muszą być z funkcji zwracającej *void pointer* oraz przyjmującej *void pointer* jako argument: `void *funkcja (void *)`.

```c
#include <stdio.h>
void* funkcjaWątku(void* arg) {
    printf("Wiadomość z nowego wątku!\n");
}
```

Przed utworzeniem nowego wątku należy określić dla niego atrybuty, można tego dokonać z użyciem funkcji [`pthread_attr_init`](https://www.man7.org/linux/man-pages/man3/pthread_attr_init.3.html):

```c
#include <pthread.h>

pthread_attr_t attr;
pthread_attr_init(&attr);
```

Gdy utworzone zostały atrybuty, można utworzyć wątek i go uruchomić. Te dwie operacje wykonywane są na raz z użyciem funkcji [`pthread_create`](https://man7.org/linux/man-pages/man3/pthread_create.3.html):

```c
#include <pthread.h>

pthread_t thread_id;
int pthread_create(&thread_id, &attr, &funkcjaWątku, NULL);
```

Możliwe jest wstrzymanie wykonywania jednego wątku do momentu zakończenia innego. Używa się do tego funkcji `pthread_join`.

```c
#include <pthread.h>

pthread_join(thread_id, NULL);
```

## Java

W środowisku uruchomieniowym Javy wątki tworzy się poprzez użycie obiektu klasy `Thread`. Kod, który ma uruchomić się w nowym wątku, powinien być w klasie implementującej interfejs [`Runnable`](https://docs.oracle.com/javase/7/docs/api/java/lang/Runnable.html) lub rozszerzającej klasę [`Thread`](https://docs.oracle.com/javase/7/docs/api/java/lang/Thread.html),

```java
/* Implementuje interfejs Runnable */
public class WątekRunnable implements Runnable {
    public void run() {
        System.out.println("Wiadomość z nowego wątku!");
    }
}


/* Rozszerza klasę Thread */
public class WątekThread extends Thread {
    public void run() {
        System.out.println("Wiadomość z nowego wątku!");
    }
}
```

Aby uruchomić nowy wątek, należy utworzyć obiekt klasy `Thread`, a następnie wywołać na niej metodę `start()`. Konstruktor klasy `Thread` pozwala na zamianę obiektu implementującego interfejs `Runnable` na zwykły obiekt klasy `Thread`.

```java
/* Uruchamianie wątku na interfejs Runnable */
WątekRunnable objektRunnable = new WątekRunnable();
Thread wątek = new Thread(objektRunnable);
wątek.start();

/* Uruchamianie wątku na klasie rozszerzającej Thread */
WątekThread objektThread = new WątekThread();
objektThread.start();
```

# Problemy wielowątkowości

## Tworzenie nowego procesu

Jednym z problemów wielowątkowości jest tworzenie procesów. Standard POSIX nie określa czy klon (*fork*) procesu ma posiadać również sklonowane wszystkie wątki, czy tylko wątek wywołujący klonowanie. Implementacja operacji klonowania jest różna dla wszystkich systemów UNIX, ważne więc jest sprawdzenie w sklonowanym procesie czy istnieją wymagane wątki.

Proces może być sklonowany wyłącznie w celu uruchomienia innego pliku wykonywalnego (z funkcją `exec`). W takim przypadku pominięcie klonowania wszystkich wątków jest przydatne, gdyż ich działanie może prowadzić do blokowania zasobów systemowych w trakcie wgrywania nowego kodu do pamięci.

## Przetwarzanie sygnału

Procesy mogą otrzymywać sygnały od innych procesów (w pewnej hierarchii). Podczas wysyłania dowolnego sygnału do procesu jednowątkowego nie ma wątpliwości, którego wątku on dotyczy. Problem pojawia się przy procesach wielowątkowych, kiedy to nie wiadomo do kogo skierowany jest sygnał. Domyślnie wszystkie sygnały są obsługiwane przez funkcje jądra systemowego, ale w programie można utworzyć własną implementację. Taki problem nie pojawia się przy niektórych sygnałach np., przerwania procesu. Sygnał ten informuje o zakończeniu działania programu, po jego otrzymaniu proces ma chwilę czasu na zakończenie/przerwanie wszystkich swoich operacji. Oznacza to, iż taki sygnał powinien trafić do każdego z wątków, gdyż każdy wykonuje operację.

Aby można było wysłać sygnał do procesu, stosuje się funkcję [`int kill(pid_t pid, int sig)`](https://www.man7.org/linux/man-pages/man3/kill.3p.html). Sygnał ten skierowany jest do całego procesu, możliwe jest jednak wysłanie sygnału do konkretnego wątku. Biblioteka `Pthread` udostępnia funkcję [`int pthread_kill(pthread_t thread, int sig);`](https://www.man7.org/linux/man-pages/man3/pthread_kill.3p.html), która kieruje sygnał do konkretnego wątku.

## Lokalna pamięć wątku

Niekiedy podczas operacji dokonywanych przez wątek przydatne jest posiadanie kopii danych. Przykładowo podczas transkrypcji wątek może zapisywać dane na istniejący blok danych. Nie jest to pożądane zachowanie, gdy z tych samych danych korzysta więcej wątków.

## Harmonogram aktywacji

Podczas działania wątku może się zdarzyć, iż wątek systemowy zostanie zablokowany przez dowolną operację np. I/O. W niektórych systemach operacyjnych wykorzystuje się *Lightweight Process* (LWP). Ma ono za zadanie dzielić każdy wątek na “oddzielne” procesy, które współdzielą ze sobą takie same dane, jak i wątki (pamięć, otwarte pliki itp.).

Używanie *LWP* eliminuje ww. problem z wątkami systemowymi, efektem ubocznym takiego rozwiązania jest istnienie wielu procesów o różnych PID składających się z tych samych danych. Dodatkowo w wirtualnym systemie plików *proc*, istnieje folder zawierający wątki identyfikowane poprzez *PID*, a metody listujące pliki/procesy wyświetlają tylko pierwotne procesy.

## Anulowanie wątku

W trakcie wykonywania wątku może dojść do sytuacji przerwania działania wątku. Może to doprowadzić do wielu problemów. Przykładowo, jeśli wątek prowadzi komunikację z innym wątkiem, to może ona zostać przerwana, poprzez co pojawią się błędy komunikacji. A dodatkowo podczas przerwania zapisu pliku lub fragmentu pamięci, dane będą niekompletne.

Sposoby zatrzymania procesu są dwa:

- **Asynchroniczny** (*Asynchronous cancellation*) Wykonywany wątek jest natychmiastowo zatrzymywany.
- **Opóźniony** (*Deferred cancellation*) Wątek, który ma zostać zatrzymany, sam okresowo powinien sprawdzać, czy nie otrzymał sygnału do zamknięcia. A następnie dokonać tego w odpowiednim momencie.

Biblioteka **pthread** (jako API POSIX) pozwala na zakończenie wątku sposobem **opóźnionym**. Metoda [`pthread_cancel(pthread_t id);`](https://man7.org/linux/man-pages/man3/pthread_testcancel.3.html) wysyła sygnał przerwania do wątku o określonym identyfikatorze `id`. Wątek ten co jakiś czas powinien ustawiać *punkty przerwań* (cancellation point), po których osiągnięciu wątek przerwie swoje działanie, jeśli otrzymał sygnał. Takie punkty ustawia się za pomocą funkcji [`pthread_testcancel();`](https://man7.org/linux/man-pages/man3/pthread_cancel.3.html).

Dla całego procesu można ustalić typ zakończenia, używając metody [`pthread_setcanceltype(int type, int *oldtype);`](https://man7.org/linux/man-pages/man3/pthread_setcancelstate.3.html), gdzie *type* to jedna z wartości:

- **PTHREAD\_CANCEL\_DEFERRED** Sposób *Opóźniony*
- **PTHREAD\_CANCEL\_ASYNCHRONOUS** Sposób *Asynchroniczny* A wartość *oldtype* to wskaźnik gdzie ma zostać zapisany poprzedni typ.

# Bibliografia

---
notice: |
	@Silberschatz2006, @StackOverflow-28476456, @Wikipedia-LWP
...