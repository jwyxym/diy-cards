-- 《<梦魇>讴歌青春》
-- 卡种：速攻魔法  卡号：65200020  字段：梦魇 (0x32a)
local s,id=GetID()
local NM=0x32a
local TOKEN_SKULL=65200900
local TOKEN_ZOMBIE=65200901

function s.initial_effect(c)
    -- ① 场上发动
    local e1=Effect.CreateEffect(c)
    e1:SetDescription("①：可以从以下选择1个发动。●从卡组将1张「<梦魇>」卡加入手卡。●在自己场上将各最多1只「骷髅士兵衍生物」「僵尸衍生物」特殊召唤，这个效果特殊召唤的怪兽在这个回合结束时破坏。")
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- ② 被除外时回收/盖放
    local e2=Effect.CreateEffect(c)
    e2:SetDescription("②：这张卡被除外的场合才能发动。这张卡加入手卡或在自己场上盖放。")
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_REMOVE)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.remtg)
    e2:SetOperation(s.remop)
    c:RegisterEffect(e2)
end

-- ① 目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    local canA=Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SKULL,0,TYPES_TOKEN,1000,1000,1,RACE_ZOMBIE,ATTRIBUTE_DARK)
    local canB=Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ZOMBIE,0,TYPES_TOKEN,1000,1000,3,RACE_ZOMBIE,ATTRIBUTE_DARK)
    local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (canA or canB)

    if chk==0 then return b1 or b2 end

    local op=Duel.SelectOption(tp,"从卡组将1张「<梦魇>」卡加入手卡","特殊召唤衍生物（可能只召唤1种）")
    e:SetLabel(op)
    if op==0 then
        e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    else
        e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
        Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
    end
end

-- ① 发动
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabel()==0 then
        Duel.Hint(HINT_SELECTMSG,tp,"选择要加入手卡的卡片")
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    else
        local ct=0
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SKULL,0,TYPES_TOKEN,1000,1000,1,RACE_ZOMBIE,ATTRIBUTE_DARK) then
            local token=Duel.CreateToken(tp,TOKEN_SKULL)
            Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
            ct=ct+1
        end
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ZOMBIE,0,TYPES_TOKEN,1000,1000,3,RACE_ZOMBIE,ATTRIBUTE_DARK) then
            local token=Duel.CreateToken(tp,TOKEN_ZOMBIE)
            Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
            ct=ct+1
        end
        if ct>0 then
            Duel.SpecialSummonComplete()
            local g=Duel.GetOperatedGroup()
            for tc in aux.Next(g) do
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
                e1:SetCode(EVENT_PHASE+PHASE_END)
                e1:SetCountLimit(1)
                e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
                e1:SetLabelObject(tc)
                e1:SetCondition(s.descon)
                e1:SetOperation(s.desop)
                e1:SetReset(RESET_PHASE+PHASE_END)
                Duel.RegisterEffect(e1,tp)
            end
        end
    end
end

function s.thfilter(c)
    return c:IsSetCard(NM) and c:IsAbleToHand()
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc and tc:IsLocation(LOCATION_MZONE) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

-- ② 除外时回收/盖放
function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() or c:IsSSetable() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.remop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if c:IsAbleToHand() and (not c:IsSSetable() or Duel.SelectOption(tp,"加入手卡","盖放到场上")==0) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    else
        Duel.SSet(tp,c)
    end
end