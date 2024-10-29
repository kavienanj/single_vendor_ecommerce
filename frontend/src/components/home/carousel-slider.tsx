import { Card, CardContent } from "@/components/ui/card"
import Autoplay from "embla-carousel-autoplay"
import {
    Carousel,
    CarouselContent,
    CarouselItem,
    CarouselNext,
    CarouselPrevious,
} from "@/components/ui/carousel"

export function CarouselComponent() {
    return (
        <Carousel className="my-6 mx-8"
            plugins={[
                Autoplay({
                    delay: 2000,
                }),
            ]}
        >
            <CarouselContent>
                {Array.from({ length: 5 }).map((_, index) => (
                    <CarouselItem key={index} className="w-full">
                        <Card className="w-full h-[40vh]">
                            <CardContent className="flex items-center justify-center p-0">
                                <img
                                    src={`/assets/slider${index + 1}.webp`}
                                    className="object-cover w-full h-[40vh] rounded-lg"
                                />
                            </CardContent>
                        </Card>
                    </CarouselItem>
                ))}
            </CarouselContent>
            <CarouselPrevious />
            <CarouselNext />
        </Carousel>
    )
}
