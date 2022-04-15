\title{Pamięć Wirtualna}
\author{Patryk 45118641800f7466ecce781cbda2de6f6d79eca9}
\date{27 Feb 2022}

\renewcommand*\contentsname{Spis treści}

\maketitle
\tableofcontents

\newpage

# Wstęp

Pamięć wirtualna pozwala na działanie procesom, bez tworzenia kolizji między sobą. Przyśpiesza ona również wykonywanie operacji, poprzez jednolite traktowanie danych.

W tej notatce, przedstawiona zostanie koncepcja pamięci wirtualnej, algorytmy oraz problemny z nią związane.

# Koncepcja pamięci wirtualnej

Pamięć wirtualna – z punktu widzenia programisty – pozwala zaadresować dane na dowolnym adresie pamięci tzn. jeśli procesor jest 64 bitowy, to możliwe jest zapisanie danych na adresie 0xFFFFFFFF (2<sup>64</sup>), pomimo iż pamięć ma fizyczny rozmiar nawet 1GiB. Taka pamięć jest mapowana na fizyczną z użyciem *tablicy mapowania*. W porównaniu do standardowego mechanizmu paginacji, pamięć wirtualna mapuje strony dla konkretnego procesu, a nie dla wszystkich adresów logicznych. Przykładowo, gdy w systemie znajdują się dwa procesy, każdy z nich chce zapisać dane na tym adresie logicznym, to w przypadku paginacji tylko jeden proces będzie mógł to zrobić, a drugi otrzyma informację, że strona pamięci nie należy do niego. 

# Segmentacja pamięci procesu

Pierwotnie zakłada się, iż proces, który jest wykonywany, powinien w całości znajdować się w pamięci operacyjnej. Bardzo często jednak takie programy zawierają wiele funkcji, które nie są wykonywane. Przykładowo, każdy program wykonuje jakieś operacje, a w przypadku napotkania jakiegoś błędu musi go rozwiązać, co jest realizowane zazwyczaj przez oddzielną funkcję programu. Taki sposób redukcji kodu jest również cechą bibliotek, które można załadować w trakcie wykonywania programu. Niestety wymagają one specjalnej implementacji od strony programisty.

Rozwiązaniem ww. problemu jest ładowanie poszczególnych stron pamięci z dysku do pamięci operacyjnej. Dzięki temu programista nie musi się martwić o implementacje funkcji, aby mogła działać jako zewnętrzna biblioteka. Taką funkcjonalność dostarcza **Demand Paging** (pol. *Paginacja zapotrzebowania*). Pozwala ona na załadowanie z pamięci masowej do pamięci operacyjnej stron, które są wykorzystywane przez proces. Dodatkiem jest algorytm **Lazy Swapper** (pol. *Leniwy podmieniacz*), który wykonuje proces *swapping*'u podobnie do innych algorytmów, lecz nie przenosi całej pamięci procesu tylko jej fragment między pamięcią operacyjną a masową.

## Zasada działania

Pamięć wirtualna nie wymaga dodatkowych usprawnień sprzętowych, wymagane jest jednak obsługiwania paginacji przez MMU (*Memory Management Unit*). Jedynym problemem wirtualizacji pamięci procesu jest stwierdzenie – bez dodatkowych operacji – czy strona pamięci znajduje się w pamięci operacyjnej, czy też masowej. Rozwiązuje się to poprzez wykorzystanie bitu *Valid-Invalid* w deskryptorach stron pamięci oraz przerywań systemowych. Bit *Valid-Invalid* pozwala określić czy strona pamięci jest prawidłowa oraz, czy znajduje się w pamięci operacyjnej. W przypadku gdy proces próbuje pozyskać dane z nieprawidłowej strony pamięci, generowany jest sygnał przerwania. Sygnał ten odbiera system operacyjny, który określa czy proces faktycznie posiada taką przestrzeń pamięci wirtualnej, jeśli nie przekazuje błąd dalej do procesu. W przeciwnym wypadku ładuje daną stronę z pamięci masowej (z pamięci swap lub standardowego systemu plików). Po załadowaniu tej strony pamięci powraca, do którego procesu ta strona dotyczy oraz wznawia jego działanie od ostatniej instrukcji, która wygenerowała błąd. Cała ta procedura nazywana jest **page fault**.

Ważnym jest, aby proces był możliwy do wznowienia tzn. aby możliwe było wykonanie tej samej instrukcji, bez kolizji danych. Z pozoru niegroźna dla spójności operacja może doprowadzić do naruszenia danych. W komputerach IBM 360 istniała instrukcja umożliwiająca przenoszenie bloków danych po pamięci. Instrukcja ta przyjmowała dwa parametry, źródło oraz miejsce docelowe danych. Zgodnie z założeniami, instrukcja ta nie zostanie wykonana, gdy jeden ze wskaźników pamięci wskazuje na nieprawidłową stronę pamięci. Problem występuje, dopiero gdy zakres operacji na pamięci przekracza sprawdzane strony tzn. gdy przenosimy dane o wielkości dwóch stron pamięci do innej lokalizacji, po przeniesieniu jednej rozpoczyna się przenoszenie drugiej, której istnienie nie zostało potwierdzone. W tym przypadku, przetworzenie przerwania przez system operacyjny oraz wznowienie działania procesu, spowoduje błędy spójności danych, których część już została przeniesiona na wskazaną lokalizację (fragment danych początkowych już skasowany). Jednym ze sposobów rozwiązania tego problemu jest dodanie mikro-kodu do instrukcji, który sprawdzi, czy całe zakresy adresów istnieją. Inny sposób zakłada wykrycie typu funkcji przez system, aby określić czy nadpisuje ona dane, jeśli tak to system powinien się postarać je przywrócić do miejsca sprzed operacji.

## Wydajność

Wirtualizacja pamięci procesu pozwala zaoszczędzić wiele pamięci operacyjnej kosztem czasu procesora. Mianowicie, opisany wcześniej sposób działania pamięci wirtualnej na każdym ze swoich etapów wykonuje dodatkowe operacje, które wykorzystują czas procesora. Jeśli wszystkie etapy pogrupujemy według wykonywanych operacji, to otrzymamy grupy tj. przetwarzanie przerwania, przenoszenie strony pamięci oraz wznawianie procesu. Przetwarzanie przerwania oraz wznowienie procesu to grupy, które zajmują różny czas procesora, w zależności od implementacji może być to od jednej mikro sekundy aż do kilku dziesięciu. Zdecydowanie najbardziej czasochłonna jest grupa przenoszenia strony pamięci, gdyż czas dostępu oraz opóźnienia dysku są rzędu milisekund. Należy jeszcze pamiętać, iż uzyskiwany jest trzykrotny dostęp do pamięci operacyjnej. Za pierwszym razem dostęp generuje przerywanie, za drugim dane zapisywane są do pamięci, natomiast za trzecim razem dane są pobierane przez proces.

Mianem wydajności określa się jak często oraz jak sprawnie przebiega proces przenoszenia stron pamięci. Jako jeden z parametrów przyjmuje się proporcję wywoływania ww. przenoszenia stron pamięci, jej wartość musi mieścić się w zakresie od 0 do 1.

Wydajność można opisać za pomocą wzoru:
$$
wydajnosc = \frac{ t_{ma} }{ f*(3*t_{ma} + t_{hda} + t_{is} + t_{cs}) + (1-f)*t_{ma} } * 100\%
$$

Gdzie:

- $f$ – Współczynnik występowania operacji przenoszenia stron pamięci.

- $t_{ma}$ – (Memory access time) Czas dostępu do pamięci operacyjnej.

- $t_{hda}$ – (Hard drive access time) Czas dostępu do danych dysku twardego.

- $t_{is}$ – (Interrupt service time) Czas wykonania przerwania systemowego.

- $t_{cs}$ – (Context switch time) Czas przełączenia procesu.


# Kopiowanie przy zapisie

Klonowanie procesu polega na wykonaniu kopii pamięci aktualnie uruchomionego procesu. Często jednak zdarza się, iż nowy proces nie wykorzystuje w pełni oddzielnych stron pamięci. Mianowicie, sklonowany proces korzysta z takiego samego kodu wykonywalnego, a od poprzedniego różni się kilkoma stronami danych. Metoda kopiowania przy zapisie pozwala na współdzielenie stron pamięci, tak długo puki jeden z procesów nie zapisze do niej danych. W takim przypadku klonowany zostaje dany fragment pamięci, a dostęp do niego otrzymuje proces, który wykonywał operację zapisu.

Sposób implementacji ww. funkcjonalności może być podobny do algorytmu przenoszenia stron pamięci procesu. Mianowicie, po utworzeniu klona procesu wspólne strony tracą prawa do zapisu. Gdy jeden z procesów wykona operację, do której nie ma dostępu, MMU wyśle sygnał przerwania. Sygnał ten powinien zostać przetworzony przez system operacyjny, mający za zadanie określenie, który proces wykonał operacje oraz na jakiej stronie pamięci. Gdy te dane są zebrane, system może wykonać kopie strony, na którą próbował odwołać się proces. Następnie przypisać do niego tę stronę oraz powtórzyć ostatnią instrukcję procesu.

# Zamiana stron pamięci

Proces przenoszenia stron między dyskiem a pamięcią operacyjną, musi w pierwszej kolejności określić lokalizację danych. W przypadku dysku nie sprawia to problemu, gdyż jest on zdecydowanie większy od pamięci operacyjnej. Natomiast przy transmisji strony do pamięci operacyjnej, może pojawić się problem, gdy ta będzie pełna. W takim przypadku strony zamienia się ze sobą, tzn. jedną przenosi się na dysk a drugą do pamięci operacyjnej.

## Schemat procesu przenoszenia stron

Aby przenieść stronę z dysku, należy określić miejsce docelowe w pamięci operacyjnej. Do tego celu wykorzystuje się *algorytmy wyszukiwania przestrzeni* (**frame-allocation algorithm**). W przypadku gdy ww. algorytm nie odnajdzie wolnej przestrzeni w pamięci operacyjnej, rozpoczyna się proces zamiany stron. Nazywany jest on również **page-replacement algorithm**. Natomiast, strona pamięci, która zostanie przeniesiona na dysk, potocznie nazywana jest *ofiarą* (**victim**).

Dodatkowym usprawnieniem w wyborze stron pamięci jest flaga **dirty bit**. Jest ona czyszczona, gdy strona trafia do pamięci operacyjnej. Ustawiona zostaje podczas operacji zapisu przez MMU. Dzięki ww. fladze algorytm wyboru ofiary ma możliwość określenia czy dana strona pamięci została już użyta.

Do testowania algorytmów przenoszenia lub wyboru stron, stosuje się **reference string**, który daje sprawiedliwe porównanie. *Reference string* to zbiór danych, zwierający sekwencję wywoływanych adresów lub bezpośrednio stron. Sekwencja ta może być generowana pseudolosowo lub zapisywana z faktycznego systemu operacyjnego.

## Algorytm FIFO

FIFO to jeden z algorytmów zamiany stron pamięci. Jego działanie polega na zbieraniu informacji, która strona znajduje się w pamięci najdłużej. Informacja ta pozwala określić która strona pamięci jako pierwsza powinna zostać zamieniona.

Algorytm ten nie jest zbyt optymalny, jest natomiast bardzo prosty w implementacji oraz zrozumieniu. Pomimo tego utworzono pojęcie **optimal
page-replacement algorithm**, którego wymaganiem jest dostęp do informacji o tym, jaka strona pamięci będzie wykorzystywana za jakiś czas. Niestety to jedno wymaganie skreśla ten algorytm, choć do jego wykonywania można użyć przewidywań aniżeli faktycznych sekwencji stron pamięci.

### Anomalia Bélády'a

Przy wykorzystaniu algorytmu FIFO do wybrania strony ofiary, można było dostrzec pewne nieprawidłowe działanie, nazwane w późniejszym czasie *anomalią Bélády'a*. Podczas testów algorytmu z tym samym *reference string*'iem możliwe było do zaobserwowania zwiększone występowanie procesu przenoszenia stron, gdy powiększono pamięć. Spowodowane było to głównie cyklicznym powtarzaniem się wymaganych stron, gdzie długość jednego cyklu była bliska ilości stron pamięci do zarządzania.

## Algorytm – Least Recently Used (LRU)

Algorytm LRU jest odwrotnością *optimal page-replacement algorithm*, który wykorzystuje dane z przeszłości do wybierania strony pamięci. Jego działanie jest również podobne do kolejki FIFO, która wybierała stronę najdawniej wprowadzoną do pamięci operacyjnej. LRU natomiast wybiera stronę pamięci, która była najdawniej użyta.

Implementacja tego algorytmu nie jest jednak prosta, wnika to z faktu, iż wymagane jest wielokrotne aktualizowane czasu dostępu. Do tego celu wykorzystuje się algorytmy przybliżające czas ostatniego użycia.

### Dodatkowe bity dostępu

Jeśli procesor wspiera flagę **dirty bit** dla stron pamięci, możliwe jest okresowe sprawdzanie, czy dana ramka została wykorzystana. Przykładowo, co 100ms wywoływane jest przerwanie systemowe, które wyszukuje wszystkie strony pamięci użyte w tym interwale czasowym. Następnie do dodatkowej zmiennej wstawiany jest ten bit, po czym całość jest przesuwana o jeden bit w celu utworzenia tzw. *timeline*'u użycia. Taką zmienną bitową można później potraktować jako liczbę, której najmniejsza wartość będzie oznaczała stronę przeznaczoną do nadpisania.

### Algorytm drugiej szansy

Algorytm ten jest usprawnieniem standardowego FIFO. Tworzy on kolejkę stron pamięci. Podczas wyszukiwania ofiary, pobiera on pierwszą od końca stronę, która nie posiada ustawionej flagi *dirty bit*. Gdy już wybierze ofiarę, wszystkie strony z ustawionym *dirty bit* przenosi na początek kolejki oraz resetuje tę flagę.

## Algorytm licznikowy

Algorytm ten wykorzystuje licznik odwołań do strony pamięci. W zależności od implementacji, jako ofiarę wybiera się stronę z najczęściej (*most frequently used* (MFU)) lub najrzadziej (*least frequently used* (LFU)) używaną. Licznik działa na podobnej zasadzie co w LRU, czyli skrypt liczący jest wywoływany co jakiś określony czas, oraz naliczane są użycia stron według ustawień flag *dirty bit*.

## Buforowanie wolnych stron pamięci

Nie jest to bezpośrednio algorytm wybierania strony ofiary, ale funkcjonalność, która zwiększa ilość dostępnych ramek pamięci przed faktycznym ich wymaganiem. Bufor posiada ograniczoną wielkość w celu uniknięcia zwolnienia większości pamięci. Taka procedura przedwczesnego zwalniania stron w pamięci operacyjnej jest przydatna do optymalizacji, gdyż daje efekt gotowości do użytku.

# Dobór ilości ramek pamięci

System operacyjny może mieć wiele ramek pamięci, gdzie kilka z nich powinny być przydzielone określonemu procesowi. Takie przydzielenie jednemu procesowi daje mu wyłączność na dostęp do tych stron pamięci, co zwalnia go z potrzeby konkurencji z innymi.

Ilość ramek pamięci do przydzielenia procesowi ma swój zakres. Mianowicie, liczba stron nie może być większa od całkowitej ilości w systemie oraz nie może być mniejsza niż wskazana wartość zależna od architektury. Wartość tą ustala się poprzez rozpatrzenie najgorszego przypadku dla jednej instrukcji, tzn. sprawdza się, ile najwięcej stron pamięci może wykorzystać operacja procesora. Przykładowo, dla instrukcji *add* przyjmujących dwa wskaźniki pamięci, najgorszym przypadkiem będzie użycie czterech stron, wynika to z tego, iż dane nie jedno bajtowe, mogą przechodzić przez swoje granice stron.

Wyróżnia się dwa algorytmy przydziału ramek pamięci, są to **equal allocation** oraz **proportional allocation**.

Do poprawnego przedstawienia algorytmów jako wzorów oznaczymy, że:
- $a_i$ – Ilość ramek przydzielonych danemu procesowi
- $q$ – Ilość procesów
- $m$ – Ilość dostępnych ramek pamięci operacyjnej
- $S$ – Rozmiar pamięci wirtualnej procesów
- $s_i$ – Rozmiar pamięci wirtualnej pojedynczego procesu

**Equal allocation** rozdziela wszystkie dostępne ramki pamięci równomiernie między procesy. $a_i = \frac{m}{q}$

**Proportional allocation** rozdziela wszystkie dostępne ramki proporcjonalnie do zadeklarowanej pamięci wirtualnej. Ten algorytm w pierwszej kolejności sumuje ilość całkowitej pamięci wirtualnej zajętej przez procesy. Następnie rozmiar pamięci wirtualnej pojedynczego procesu jest dzielony przez wcześniej obliczoną sumę, co daje współczynnik w zakresie od 0 do 1.

$S = \sum_{i=0}^{q}{s_i}$

$a_i = \frac{s_i}{S} * m$

Taki sposób przydzielania ramek pamięci konkretnym procesom wprowadza nowy system dystrybucji stron, jakim jest **local replacement**. Pozwala on na zamianę stron pamięci z własnych zasobów, co anuluje problem konkurencji procesów. Wytwarza on natomiast nowy, jakim jest problem równości procesów. W systemie mogą istnieć procesy, które mają wyższy priorytet, a tymczasowe zwiększenie liczby ramek pamięci pomogłyby przyśpieszyć ich wykonanie. Domyślnie wykorzystuje się jednak **global replacement**, który nie tworzy mniejszych puli ramek pamięci dla każdego z procesów, a operuje na całym zbiorze, umożliwiając konkurencję.

## Przeładowanie

Terminem "*przeładowanie*" określa się proces, który większość swojego czasu spędza na paginacji aniżeli faktycznym wykonywaniu kodu. Najczęstszym momentem, w którym dochodzi do *przeładowania* jest zmniejszenie się liczby dostępnych ramek dla procesu poniżej wartości minimalnej. Gdy procesy nie są wykonywane, jest to równoznaczne ze spadkiem stopnia użycia procesora. System aby być jak najwydajniejszym, doda kolejne procesy, co nie jest pożądanym efektem, gdyż jeszcze bardziej ogranicza dostępne ramki pamięci. Rozwiązaniem tego problemu jest wymuszenie korzystania z **local replacement**. Takie statyczne przydzielanie ramek procesom, eliminuje problem przywłaszczenia. Innym sposobem jest priorytetyzowanie procesów tak, aby zadania ważniejsze lub mające mniej niż wymaganą liczbę ramek pamięci, otrzymały dodatkowe strony w celu szybszego zakończenia swojego działania.

# Pliki mapowane w pamięci

Dzięki wykorzystaniu mapowania pamięci możemy zapisywać pliki z dysku wirtualnie. Taka możliwość jest w stanie znacząco przyśpieszyć wykonanie procesu oraz zmniejszyć wykorzystanie dysku w celu dostępu do danych. Fragment pliku jest ładowany do pamięci operacyjnej w momencie wywołania przerwania systemowego przez MMU. Tak załadowany plik można edytować, a procesor co jakiś czas będzie uruchamiał przerwanie systemowe, aby sprawdzić, czy fragment został nadpisany. Jeśli tak, zmiany wprowadza również na dysku.

# Bibliografia

---
nocite: |
  @Silberschatz2006
...