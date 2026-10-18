--姬装战线·TCR
--字段：姬装战线（0xFA1）

local s,id,o=GetID()
local SET_JI_ZHUANG=0xFA1

function s.initial_effect(c)
    --同调召唤
    aux.AddSynchroProcedure(c,
        aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),
        aux.NonTuner(Card.IsAttribute,ATTRIBUTE_EARTH),
        1, 99)
    c:EnableReviveLimit()
    
    --①：这张卡同调召唤的场合，或者对方把怪兽特殊召唤的场合才能发动。场上的卡全部破坏。
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.descon1)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
    
    local e1b=Effect.CreateEffect(c)
    e1b:SetDescription(aux.Stringid(id,0))
    e1b:SetCategory(CATEGORY_DESTROY)
    e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetProperty(EFFECT_FLAG_DELAY)
    e1b:SetCountLimit(1,id)
    e1b:SetCondition(s.descon2)
    e1b:SetTarget(s.destg)
    e1b:SetOperation(s.desop)
    c:RegisterEffect(e1b)
    
    --②：只要这张卡在怪兽区域存在，双方玩家都不能把自己场上的表侧表示的「姬装战线」怪兽解放，控制权不能变更。
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_RELEASE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1,1)
    e2:SetTarget(s.indtg)
    c:RegisterEffect(e2)
    
    local e2b=Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_FIELD)
    e2b:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    e2b:SetRange(LOCATION_MZONE)
    e2b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2b:SetTargetRange(1,1)
    e2b:SetTarget(s.indtg)
    e2b:SetValue(1)
    c:RegisterEffect(e2b)
    
    --③：这张卡在墓地存在的场合，自己场上的表侧表示的「姬装战线」怪兽被战斗·效果破坏的场合才能发动。这张卡特殊召唤。那之后，可以从自己的墓地·除外状态把1张「姬装战线」卡加入手卡。
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+o)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

--===============================================================================
-- ①效果
--===============================================================================
function s.descon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.descon2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.oppfilter,1,nil,1-tp)
end

function s.oppfilter(c,tp)
    return c:IsControler(tp)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #g==0 then return end
    Duel.Destroy(g,REASON_EFFECT)
    
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

function s.splimit(e,c)
    return not (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH))
end

--===============================================================================
-- ②效果
--===============================================================================
function s.indtg(e,c)
    return c:IsSetCard(SET_JI_ZHUANG) and c:IsFaceup() 
        and c:IsControler(e:GetHandlerPlayer())
end

--===============================================================================
-- ③效果（参考メメント・カクタス写法）
--===============================================================================
function s.cgfilter(c,tp)
    return c:IsPreviousControler(tp)
        and c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsPreviousPosition(POS_FACEUP)
        and c:IsPreviousSetCard(SET_JI_ZHUANG)
        and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    -- 自己场上表侧表示的「姬装战线」怪兽被战斗·效果破坏
    -- 且效果发动者自身不是本次被破坏的卡（即已经在墓地）
    return eg:IsExists(s.cgfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end

function s.thfilter(c)
    return c:IsSetCard(SET_JI_ZHUANG) and c:IsAbleToHand()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    
    --那之后，可以回收1张「姬装战线」卡
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    if #g==0 then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
    
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=g:Select(tp,1,1,nil)
    if #sg>0 then
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
end
