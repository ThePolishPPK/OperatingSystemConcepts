\title{Synchronizacja procesów}
\author{Patryk 45118641800f7466ecce781cbda2de6f6d79eca9}
\date{19 Dec 2021}

\renewcommand*\contentsname{Spis treści}

\maketitle
\tableofcontents

\newpage

# Potrzeba synchronizacji

Podczas pracy dwóch procesów współdzielących dane może dojść do momentu, kiedy to obydwa będą operować na tych samych zbiorach. Przykładem takiego działania jest komunikacja między procesami, wykorzystując metodę *Message Passing*’u. W takiej komunikacji wykorzystuje się liczniki, względem których ustalane są najnowsze dane. Gdy synchronizacja między procesami nie występuje, może dojść do rozbieżności między wartością licznika a stanem rzeczywistym. Takie fragmenty kodu, w których wykonywane są operacje, nazywa się sekcjami krytycznymi (*critical section*).

# Problem sekcji krytycznej

Sekcja krytyczna może dotyczyć kilku procesów, aby była wykonywana tylko w jednym, należy ustawić odpowiednią flagę. Problem może się pojawić, gdy jeden proces nadużywa praw do sekcji krytycznej. Nadużycie takie polega na nierównym dostępie do sekcji.

Sposobem na rozwiązanie takiego problemu jest podział na sekcje:

1.  **Wejściowa** (*Entry Section*) Proces w niej oczekuje na otrzymanie pozwolenia na wejście do sekcji krytycznej.
2.  **Krytyczna** (*Crirical Section*) Proces wchodzi do tej sekcji po otrzymaniu wyłączności na wykonanie.
3.  **Wyjściowa** (*Exit Section*) Po zakończeniu operacji na sekcji krytycznej, proces „oznajmia” to w ustalony sposób, a następnie pozwala na wejście innemu procesowi.

Algorytm implementujący *sekcję krytyczną* powinien spełniać następujące warunki:

- **Wzajemne wykluczenie** (*Mutual Exclusion*) Jeśli jeden proces wykonuje już sekcję krytyczną, to żaden inny w tym samym czasie nie może rozpocząć w niej działania.
- **Postępowość** (*Progress*) Gdy sekcja krytyczna nie jest wykonywana, a istnieją procesy, które zadeklarowały poprzez flagę chęć rozpoczęcia operacji, to powinien zostać wybrany kolejny. Powinien on być wybierany jak najsprawiedliwiej pod względem poprzednich przydziałów.
- **Ograniczone oczekiwanie** (*Bounded Waiting*) Aby udzielić jak najsprawiedliwszego dostępu do sekcji krytycznych, to powinien istnieć limit czasu lub ilości wejść do sekcji.

# Rozwiązanie Peaterson’a

W *sekcji wejściowej* tego algorytmu ustawiana jest flaga wejścia do sekcji krytycznej. Proces oczekuje na swoją kolej przykładowo poprzez ciągłe sprawdzanie, czy wskaźnik dostępu wskazuje na niego. Gdy już uzyskał dostęp, zmienia swoją flagę wejścia i wykonuje kod w sekcji krytycznej. Po zakończeniu sekcji krytycznej trafia do wyjścia, gdzie zmienia wartość zmiennej dostępu na drugi proces.

Algorytm ten obsługuje wyłącznie dwa procesy, istnieją jednak rozszerzenia pozwalające na obsługiwanie nieskończonej ilości.

# Synchronizacja sprzętowa

Korzystając z instrukcji procesora, można redukować ilość cykli do zaktualizowania flag. Dodatkowo wyłączenie przerwań w procesorze, daje pewność, iż algorytm kolejkowania nie zatrzyma skryptu przydzielającego prawo do wejścia w sekcję krytyczną. Takie przerwanie mogłoby doprowadzić do wejścia dwóch procesów do swoich sekcji krytycznych.

Wyróżnia się trzy główne typy algorytmów synchronizacji:

- Test and Set
- Swap
- Compare and Swap

## Test and Set

Taki algorytm synchronizacji powinien wykonać kopię flagi dostępu, a następnie zamienić oryginał na *true* i zwrócić kopię. Kod implementujący fragment wykonania kopii oraz podmiany oryginału, powinien zostać umieszczony w sekcji bez przerywań. Zwracanie kopii nie musi być zabezpieczane, gdyż jest to wartość lokalna i nie zależy od niej żaden inny proces. Sekcja bez przerywań to taka, w której niemożliwe jest przerwanie wykonywania kodu. Sekcję taką często implementuje się poprzez wyłączenie przerywań na procesorze, pomimo iż jest to kosztowny czasowo proces.

W języku C i C++ istnieje gotowa implementacja, funkcja deklarowana jest w bibliotece `stdatomic.h`. Ma ona schemat: [`_Bool atomic_flag_test_and_set( volatile atomic_flag* obj );`](https://en.cppreference.com/w/c/atomic/atomic_flag_test_and_set)

Przykładowa implementacja w C:

```C
bool lock; // Wartość współdzielona między procesami

bool test_and_set(bool *target) {
    /* Rozpoczyna skecję bezpieczną (dodatkowa implementacja) */
    bool cpy = *target;
    *target = true;
    /* Kończy sekcję bezpieczną (dodatkowa implementacja) */
    return cpy;
}

int main() {
    do {
        while (test_and_set(&lock)); // Oczekuje na zwolnienie sekcji
        /* Sekcja krytyczna */
        lock = false; // Sekcja wyjściowa
        /* Pozostały kod */
    } while (true);
}
```

## Swap

Metoda ta podobnie jak *Test and Set* ma za zadanie podmienić wartość zmiennej dostępu. Do algorytmu wprowadza się dwie wartości, wskaźnik na zmienną dostępu oraz oczekiwania (zawsze równa *true*). W operacji tej podmieniane są wartości podane jako argument. Jeśli po zakończeniu funkcji lokalna zmienna oczekiwania jest równa `false` to znaczy, iż otrzymano zezwolenie na wejście do sekcji krytycznej. Metoda *Swap* w przeciwieństwie do *Test and Set* nie zwraca żadnej wartości oraz cała powinna zawierać się w sekcji bezpiecznej.

## Compare and Swap

Metoda ta rozszerza *Test and Set* o obsługę wielu procesów. Modyfikuje ona minimalnie zasadę działania *Test and Set*, wartość zmiennej dostępu jest liczbą oznaczającą proces (najczęstszej PID). Podczas implementacji należy ustalić jaka wartość będzie posiadać zmienna dostępu, jeśli żaden proces nie będzie znajdował się w sekcji krytycznej (może to być np. *-1*). Zmienna dostępu jest zmieniana, gdy jej wartość jest równa oczekiwanej. W sekcji wyjściowej wartość zmiennej dostępu powinna posiadać identyfikator kolejnego procesu, który jest w stanie oczekiwania, jeśli gdy to możliwe, w przeciwnym wypadku domyślną.

Implementacja dla C znajduje się w bibliotece `stdatomic.h` jako funkcja [`_Bool atomic_compare_exchange_strong(volatile A* obj, C* expected, C desired)`](https://en.cppreference.com/w/c/atomic/atomic_compare_exchange)

# Mutex

Gotowym rozwiązaniem dla synchronizacji jest *mutex* (skrót od *MUTual EXclusion*). Dostarcza on funkcje rozpoczęcia i zakończenia bloku sekcji krytycznej. Proces oczekiwania na dostęp do sekcji krytycznej działa podobnie do poprzednich przykładów. Takie zamykanie programu w pętli nazywa się *spin lock*’iem.

Standard POSIX dla wątków udostępnia API *mutex*. Definicje wszystkich funkcji znajdują się w bibliotece `pthread.h`.

Przykładowe użycie POSIX’owego *mutex*’u w C:

```C
#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

char buffer[128];

void *runner(void *arg) {
    // Opóźnia wykonanie o 100ms (nie może być przed blokadą w funkcji main)
    usleep(100000);
    // Sekcja wejściowa (Oczekuje na dostęp do sekcji krytycznej)
    pthread_mutex_lock(arg);
    // Sekcja krytyczna
    printf("Bufor: %s\n", buffer);
    // Sekcja wyjściowa (Zwalania sekcję krytyczną)
    pthread_mutex_unlock(arg);
}

int main() {
    // Definiuje typ "fast mutex"
    pthread_mutex_t mid = PTHREAD_MUTEX_INITIALIZER;
    pthread_t tid;
    const char *text = "Proszę państwa, nasz samolot nie poleci do Krakowa, ponieważ na tamtejszym lotnisku rozpościera się obszar mgły.";

    // Inicjalizuje mutex z domyślnymi atrybutami
    pthread_mutex_init(&mid, NULL);

    pthread_create(&tid, NULL, runner, &mid);

    // Sekcja wejściowa (Oczekuje na dostęp do sekcji krytycznej)
    pthread_mutex_lock(&mid);
    // Sekcja krytyczna
    for (int q=0; q<strlen(text); q++) {
        usleep(50000);	// Opóźnia wynik (Aby był wdoczny "gołym" okiem)
        buffer[q] = text[q];
    }
    // Sekcja wyjściowa (Zwalania sekcję krytyczną)
    pthread_mutex_unlock(&mid);

    pthread_join(tid, NULL);
    // Utylizuje mutex'a który nie jest już używany
    pthread_mutex_destroy(&mid);
}
```

# Semafory (*Semaphore*)

Semafor to ogólna nazwa na algorytm dostępu do zasobu. Dzieli się je na dwa typy: **Licznikowe** (*Counting Semaphore*) oraz **Binarne** (*Binary Semaphore*). Logicznie semafor jest podzielony na dwie metody: oczekiwania (*wait*) oraz sygnalizacji (*signal*). Semafor *licznikowy* zezwala na dostęp do zasobu więcej niż jednemu podmiotowi. Natomiast semafor *binarny* pozwala tylko jednemu podmiotowi na dostęp.

Przykładowa implementacja metod w pseudokodzie wygląda następująco:

```
// L - Licznik/"Ilość możliwych podmiotów do przydzielenia"

wait(L) {
    while (L <= 0);
    L--;
}

signal(L) {
    L++;
}
```

*Mutex* jest bardzo podobny do semafora *binarnego*, różni się wyłącznie koncepcją logiczną. Dodatkowym atutem *mutex*’a jest to, iż tylko proces, który wykonuje sekcję krytyczną, może zwolnić blokadę.

## Problem semafora prostego

Problemem powyższej implementacji semafora jest brak sprawiedliwej kolejności dostępu do zasobu. Wynika to z tego, iż proces, który jest w danym momencie wykonywany, może uzyskać dostęp szybciej do procesu, który “poprosił” o zasób wcześniej. Wynika to z kolejkowania procesów w systemie, które nie gwarantuje ułożenia procesów względem wydania prośby o zasób. Można to rozwiązać z użyciem listy procesów, do której zapisywane będą kolejne procesy proszące o zasób. Należy więc dodać kolejne dwie metody: blokującą (*blocking*) oraz zwalniającą (*wakeup*).

Przykładowa implementacja metod w pseudokodzie:

```
typedef struct {
    int value;	// Licznik wolnych zasobów
    int *list;	// Lista procesów chcących uzyskać dostęp do zasobu
    int count;	// Ilość procesów
} semaphore;

block (semaphore S, int *pos) {
    while (pos >= S->list);
    S->value--;
    S->count--;
}

wait (semaphore S) {
    if (S->value <= 0) {
        int *pos = S->list + count;
        *pos = pid();
        S->count++;
        block(S, pos);
    } else {
        S->value--;
    }
}

wakeup (semaphore S) {
    S->list += 1;	// Przesunięcie wskaźnika procesów o 1 dalej
}

signal (semaphore S) {
    S->value++;
    wakeup(S);
}

```

## Deadlock

Do niepożądanej sytuacji może dojść, gdy używamy zagnieżdżonych semaforów. Do takiej sytuacji dochodzi, gdy jeden proces w swoim bloku krytycznym zażąda dostępu do kolejnego bloku krytycznego drugiego procesu, a ten wymaga pierwszego. Gdy w takiej sytuacji zabraknie zasobów do przydziału, to procesy nigdy się nie odblokują. Taki stan nazywa się **deadlock**.

Wizualizacja *deadlock*’a:

- S - Semafor 1
- Q - Semafor 2

| Proces 1 | Proces 2 |
| --- | --- |
| wait(S); | wait(Q); |
| wait(Q); | wait(S); |
| …   | …   |
| …   | …   |
| …   | …   |
| signal(S); | signal(Q); |
| signal(Q); | signal(S); |

## Odwrócenie priorytetu

W systemach operacyjnych istnieje priorytetyzowanie procesów. Procesy pracujące z PPID (Process Parent ID - Identyfikator procesu nadrzędnego) jądra systemowego, posiadają najwyższy priorytet dostępu do zasobów i wykonania. Nie mogą one jednak przerwać działania innego procesu, który korzysta z wymaganego zasobu. Prowadzi to do zamiany priorytetu procesów, gdyż proces o wyższym priorytecie oczekuje na zakończenie procesu o niższym priorytecie. Taka sytuacja nazywa się **odwróceniem priorytetu**.

Przykładem takiego zdarzenia jest awaria misji **“[Mars Pathfinder](https://www3.nd.edu/~cpoellab/teaching/cse40463/slides6.pdf)”**, w której proces *ASI/MET* (z niższym priorytetem) zablokował zasób, którego wymagał proces *bc_dist* (wyższy priorytet). Proces *ASI/MET* będąc w swojej sekcji krytycznej, został przerwany na rzecz procesów średniego priorytetu. Tak opóźniany proces *bc_dist* został powodem błędu procesu *watchdog* (sprawdzał on poprawność działania systemu). Gdy *watchdog* stwierdzał błędy w systemie, dokonywał restartu.

### Przejęcie priorytetu

Jednym ze sposobów na uniknięcie awarii w wyniku odwrócenia priorytetu jest *przejęcie priorytetu*. Metoda ta polega na tymczasowym uzyskaniu najwyższego możliwego priorytetu, jaki posiada proces oczekujący za zablokowany zasób. Działanie to ma za zadanie przyśpieszyć zwolnienie zasobu.

# Klasyczne problemy synchronizacji

## Ograniczony Bufor

Gdy dwa procesy współdzielą między sobą bufor, może dojść do sytuacji odczytu przez jeden proces, gdy drugi zapisuje. Doprowadzi to do niespójności danych, w takim wypadku używa się *mutex*’u. Dodatkowy problem pojawia się, gdy jeden proces blokuje bufor, aby sprawdzić, czy można już zapisywać lub odczytywać. Rozwiązaniem takiego problemu jest użycie dwóch dodatkowych semaforów: odczytu i zapisu. Semafory te powinny być licznikowe, gdyż odczyt zawiera ilość elementów możliwych do odczytania a zapis ilość wolnych miejsc do zapisania. Jeśli proces chce odczytać wiadomość z buforu, korzysta z semafora odczytu w sekcji wejścia, sekcja wyjścia natomiast powinna zwalniać semafor zapisu, gdyż jeden element został zabrany oraz zwolnione zostało miejsce do zapisu. Proces, który zapisuje dane, robi analogicznie. Dodatkowo po przejściu przez semafor odczytu i zapisu, obydwa procesy muszą skorzystać z *mutex*’a.

## Problem zapisu i odczytu

Gdy rozpatrzymy przykład bazy danych, to zapisywać może jeden proces. Spełnia to założenia semaforów, ale gdy chcemy już odczytać, nie ma to znaczenia w ile procesów. Klasyczny semafor nie daje rozwiązania tego problemu, gdyż pozwala na dostęp tylko określonej ilości procesów. Rozwiązaniem tego problemu utworzenie dodatkowej zmiennej przechowującej ilość procesów czytających zasób. Proces chcący rozpocząć czytanie powinien zwiększyć licznik i sprawdzić, czy równy 1, jeśli równy to wymagane jest zablokowanie zasobu z użyciem *wait*. Gdy natomiast licznik jest większy od 1, oznacza to, iż inny proces wcześniej zablokował zasób w celu odczytu. W sekcji wyjściowej należy zmniejszyć licznik i sprawdzić jego wartość. Gdy wartość licznika jest równa 0, oznacza to, iż ten proces jest ostatnim, który odczytuje zasób i powinien zwolnić semafor zapisu.

Implementacja w pseudokodzie:

```
semaphore zasóbS;
semaphore licznikS;
int licznik = 0;

odczyt () {
    wait(licznikS);
    licznik++;
    if (licznik == 1) // Proces jest pierwszym odczytującym
        wait(zasóbS);
    signal(licznikS);
    
    /* Sekcja krytyczna */
    
    wait(licznikS);
    licznik--;
    if (licznik == 0)  // Proces jest ostatnim odczytującym
        signal(zasóbS);
    signal(licznikS);
}

zapis () {
    wait(zasóbS);
    /* Sekcja krytyczna */
    signal(zasóbS);
}
```

# Monitory

Wspomniane wcześniej metody wzajemnego wykluczenia (tj. *mutex* oraz *semaphore*), mogą działać niepoprawnie, gdy zostaną nieprawidłowo użyte lub wykonane. Z pomocą przychodzą monitory, które zwalniają programistę z wymogu implementacji *mutex*’ów oraz *semafor*ów. Monitor to obiekt, który posiada metody operujące na danym zasobie. Kod klasy, na jakiej bazuje monitor, jest dołączany jako biblioteka, poprzez co nie jest wymagana wielokrotna implementacja tych samych funkcji.j metody wzajemnego wykluczenia (tj. *mutex* oraz *semaphore*), mogą działać niepoprawnie, gdy zostaną nieprawidłowo użyte lub wykonane. Z pomocą przychodzą monitory, które zwalniają programistę z wymogu implementacji *mutex*’ów oraz *semafor*ów. Monitor to obiekt, który posiada metody operujące na danym zasobie. Kod klasy, na jakiej bazuje monitor, jest dołączany jako biblioteka, poprzez co nie jest wymagana wielokrotna implementacja tych samych funkcji.

# Implementacje synchronizacji

## POSIX

### Mutex

Mutex’y w standardzie POSIX dostępne są tylko dla wątków w obrębie jednego procesu. Definicja funkcji należy do biblioteki `pthread.h`.

Mutex’y tworzone są z użyciem funkcji [`int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutexattr_t *mutexattr);`](https://www.man7.org/linux/man-pages/man3/pthread_mutex_init.3p.html). Usuwane [`int pthread_mutex_destroy(pthread_mutex_t *mutex);`](https://www.man7.org/linux/man-pages/man3/pthread_mutex_destroy.3p.html).

Blokowanie zasobu realizowane jest funkcją [`int pthread_mutex_lock(pthread_mutex_t *mutex);`](https://www.man7.org/linux/man-pages/man3/pthread_mutex_lock.3p.html). A zwalnianie z [`int pthread_mutex_unlock(pthread_mutex_t *mutex);`](https://www.man7.org/linux/man-pages/man3/pthread_mutex_unlock.3p.html).

### Semaphore

Metody dla semaforów znajdują się w bibliotece `semaphore.h` i są dostępne od wersji POSIX.1-2001.

Tworzenie semaforów zostało podzielone ze względu na sposób udostępniania:

- **Nazwany** Semafory tworzone są z metodą [`sem_t *sem_open(const char *name, int oflag, mode_t mode, unsigned int value);`](https://man7.org/linux/man-pages/man3/sem_open.3.html). Identyfikuje je się poprzez nazwę podawaną jako argument `name`. Metoda tworząca zwraca adres semafora o typie **sem_t**.
- **Nienazwany** Semafory tworzone są z metodą [`int sem_init(sem_t *sem, int pshared, unsigned int value);`](https://www.man7.org/linux/man-pages/man3/sem_init.3.html). Przekazywane są poprzez współdzieloną pamięć, której adres zapisany jest w parametrze `sem`.

Sekcja wejścia wykonywana jest z pomocą funkcji [`int sem_wait(sem_t *sem);`](https://www.man7.org/linux/man-pages/man3/sem_wait.3.html). A wyjściowa [`int sem_post(sem_t *sem);`](https://www.man7.org/linux/man-pages/man3/sem_post.3.html).

Usuwanie semafora *nienazwanego* wykonuje się funkcją [`int sem_destroy(sem_t *sem);`](https://man7.org/linux/man-pages/man3/sem_destroy.3.html), *nazwany* natomiast z [`int sem_unlink(const char *name);`](https://man7.org/linux/man-pages/man3/sem_unlink.3.html).

## Linux

Linux pozwala na wykonywanie operacji matematycznych w trybie bez przerywań. Odpowiada za to biblioteka `stdatomic.h`. Wymagane jest posiadanie zmiennej liczbowej, przekonwertowanej na *Atomic* z użyciem macro **_Atomic( type )**.

Operacje matematyczne na liczbach *Atomic*:
- Dodawanie
	- [atomic_add](https://manpages.debian.org/unstable/opencl-1.2-man-doc/atomic_add.3clc.en.html)
	- [atom_add](https://manpages.debian.org/unstable/opencl-1.2-man-doc/atom_add.3clc.en.html)
	- [atomic_fetch_add](https://en.cppreference.com/w/c/atomic/atomic_fetch_add)	(Standard C)
- Odejmowanie
	- [atomic_sub](https://manpages.debian.org/unstable/opencl-1.2-man-doc/atomic_sub.3clc.en.html)
	- [atom_sub](https://manpages.debian.org/unstable/opencl-1.2-man-doc/atom_sub.3clc.en.html)
	- [atomic_fetch_sub](https://en.cppreference.com/w/c/atomic/atomic_fetch_sub)	(Standard C)
- Operator AND
	- [atomic_and](https://manpages.debian.org/unstable/opencl-1.2-man-doc/atomic_and.3clc.en.html)
	- [atom_and](https://manpages.debian.org/unstable/opencl-1.2-man-doc/atom_and.3clc.en.html)
	- [atomic_fetch_and](https://en.cppreference.com/w/c/atomic/atomic_fetch_and)	(Standard C)
- Operator OR
	- [atomic_or](https://manpages.debian.org/unstable/opencl-1.2-man-doc/atomic_or.3clc.en.html)
	- [atom_or](https://manpages.debian.org/unstable/opencl-1.2-man-doc/atom_or.3clc.en.html)
	- [atomic_fetch_or](https://en.cppreference.com/w/c/atomic/atomic_fetch_or)	(Standard C)
- Operator XOR
	- [atomic_xor](https://manpages.debian.org/unstable/opencl-1.2-man-doc/atomic_xor.3clc.en.html)
	- [atom_xor](https://manpages.debian.org/unstable/opencl-1.2-man-doc/atom_xor.3clc.en.html)
	- [atomic_fetch_xor](https://en.cppreference.com/w/c/atomic/atomic_fetch_xor)	(Standard C)
- Zamiana wartości
	- [atomic_xchg](https://manpages.debian.org/unstable/opencl-1.2-man-doc/atomic_xchg.3clc.en.html)
	- [atom_xchg](https://manpages.debian.org/unstable/opencl-1.2-man-doc/atom_xchg.3clc.en.html)
	- [atomic_exchange](https://en.cppreference.com/w/c/atomic/atomic_exchange) (Standard C)

## C++

Standard C++ dodaje swoją implementację *mutex*'ów. Odpowiada za nią biblioteka [`mutex`](https://en.cppreference.com/w/cpp/header/mutex) oraz [`shared_mutex`](https://en.cppreference.com/w/cpp/header/shared_mutex).

# Bibliografia

---
notice: |
	@Silberschatz2006, @Mars-Pathfinder, @GFG-Synchronization, @Wikipedia-Monitor, @StackOverflow-38159668
...