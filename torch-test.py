import os
import torch

print("running...")
print(torch.cuda.is_available())
assert torch.cuda.is_available()

print('HSA_OVERRIDE_GFX_VERSION =', os.environ.get('HSA_OVERRIDE_GFX_VERSION', None))

device = torch.device('cuda')


input_ = torch.rand(1024, device=device)
print("input:", input_.cpu())

model = torch.nn.Sequential(
    torch.nn.Linear(1024, 2048),
    torch.nn.ReLU(),
    torch.nn.Linear(2048, 16)
).to(device)
print("model-lin:", model)

print(model(input_).cpu())

model = torch.nn.Sequential(
    torch.nn.Unflatten(0, (4, 256)),
    torch.nn.Conv1d(4, 8, 17),
    torch.nn.MaxPool1d(8),
    torch.nn.ReLU(),
    torch.nn.Flatten(0, -1),
    torch.nn.LazyLinear(16)
).to(device)
print("model-conv:", model)

print(model(input_).cpu())


