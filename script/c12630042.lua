--姬装战线·超机动
--字段：姬装战线（0xFA1）

local s,id,o=GetID()
local SET_JI_ZHUANG=0xFA1

function s.initial_effect(c)
    --①：以自己场上1张里侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「姬装战线」怪兽特殊召唤。
    --对方场上有怪兽存在的场合，可以再从卡组把1张「姬装战线」魔法·陷阱卡加入手卡。
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    --②：盖放的这张卡被效果破坏的场合才能发动。这张卡加入手卡。
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+o)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.desfilter(c)
    return c:IsFacedown()
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_JI_ZHUANG) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.thfilter(c)
    return c:IsSetCard(SET_JI_ZHUANG) and c:IsType(TYPE_SPELL+TYPE_TRAP)
        and c:IsAbleToHand()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.desfilter(chkc) end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    
    --破坏里侧表示卡
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
    
    --从卡组特殊召唤
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g==0 then return end
    if Duel.SpecialSummon(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)==0 then return end
    
    --那之后，对方场上有怪兽的场合，可以检索魔陷
    if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0 then return end
    if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
    
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #sg>0 then
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
    
    --自肃
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_SZONE) 
        and c:IsPreviousPosition(POS_FACEDOWN)
        and c:IsPreviousControler(tp)
        and c:IsReason(REASON_EFFECT)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end

function s.splimit(e,c)
    return not (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH))
end
