# Rebuilding the full pipeline including visualization

import numpy as np
from sympy import nextprime, isprime
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from PIL import Image
import matplotlib.pyplot as plt

PRIME_DIGIT = 35

# 1. Generate n-digit primes
def generate_n_digit_primes(n, count):
    start = 10**(n - 1)
    primes = []
    p = nextprime(start)
    while len(primes) < count:
        primes.append(p)
        p = nextprime(p)
    return primes

# 2. Generate n-digit non-primes
def generate_n_digit_non_primes(n, count):
    import random
    non_primes = set()
    while len(non_primes) < count:
        candidate = random.randint(10**(n - 1), 10**n - 1)
        if not isprime(candidate):
            non_primes.add(candidate)
    return list(non_primes)

# 3. Create digit-diff matrix from number
def number_to_image_matrix(number):
    num_str = str(number)
    n = len(num_str)
    matrix = np.zeros((n, n), dtype=np.uint8)

    for i in range(n):
        for j in range(n):
            a = int(num_str[i])
            b = int(num_str[j])
            matrix[i, j] = abs(a - b) * 28  # scale to 0-252
    return matrix

# 4. Resize to uniform image size
def resize_to_uniform_image(matrix, size=(32, 32)):
    img = Image.fromarray(matrix)
    img_resized = img.resize(size, Image.BICUBIC)
    return np.array(img_resized).flatten()

# 5. Generate image dataset
def generate_image_dataset(primes, non_primes, size=(32, 32)):
    X_img = []
    y_img = []

    for p in primes:
        mat = number_to_image_matrix(p)
        img_vec = resize_to_uniform_image(mat, size)
        X_img.append(img_vec)
        y_img.append(1)

    for np_ in non_primes:
        mat = number_to_image_matrix(np_)
        img_vec = resize_to_uniform_image(mat, size)
        X_img.append(img_vec)
        y_img.append(0)

    return np.array(X_img), np.array(y_img)

# 6. Visualization
def show_sample_images(X, y, count=5, image_size=(32, 32)):
    indices = np.random.choice(len(X), size=count, replace=False)
    fig, axs = plt.subplots(1, count, figsize=(count * 2, 2))
    for i, idx in enumerate(indices):
        image = X[idx].reshape(image_size)
        label = "Prime" if y[idx] == 1 else "Non-prime"
        axs[i].imshow(image, cmap='gray', interpolation='nearest')
        axs[i].axis('off')
        axs[i].set_title(label)
    plt.tight_layout()
    plt.show()

# 7. Main routine
if __name__ == "__main__":
    digits = PRIME_DIGIT
    prime_count = 200
    non_prime_count = 200

    print("채굴 중...")
    primes = generate_n_digit_primes(digits, prime_count)
    non_primes = generate_n_digit_non_primes(digits, non_prime_count)

    print("이미지 변환 중...")
    X, y = generate_image_dataset(primes, non_primes, size=(32, 32))
    X = X.astype("float32") / 255.0

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    print("MLP 학습 중...")
    model = MLPClassifier(hidden_layer_sizes=(128, 64), activation='relu', max_iter=1000, random_state=42)
    model.fit(X_train, y_train)

    acc = model.score(X_test, y_test)
    print(f"최종 정확도: {acc:.4f}")

    # Show random sample images
    show_sample_images(X, y, count=5, image_size=(32, 32))
