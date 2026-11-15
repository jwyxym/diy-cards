-- 饮泣的「爱人」
-- ID: 15040028
-- 4星 光 魔法师 效果
-- 「千早爱音」字段：0xb12
-- 「春日影」：26062911
-- 「「死亡」的子弹」：15040016
local s,id=GetID()
function s.initial_effect(c)
aux.AddCodeList(c,26062911)  -- 此卡记述「春日影」

    -- ① 把这张卡从手卡丢弃才能发动，选择以下效果之一
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE+CATEGORY_REMOVE+CATEGORY_SSET)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost1)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    -- ② 自己场上的「千早爱音」怪兽被破坏的场合，可以作为代替把墓地的这张卡除外
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)
end

-- ① cost：把这张卡从手卡丢弃
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end

-- ① 选项1对象：卡组「千早爱音」怪兽（可加手或可特召）
function s.thfilter(c,e,tp)
    return c:IsSetCard(0xb12) and c:IsType(TYPE_MONSTER)
        and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ① 选项2对象：卡组「春日影」或记述「春日影」的魔法·陷阱卡
function s.setfilter(c)
    return (c:IsCode(26062911) or aux.IsCodeListed(c,26062911))
        and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

-- ① 目标
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
    if chk==0 then return b1 or b2 end
    local ops={}
    local opval={}
    if b1 then
        ops[#ops+1]=aux.Stringid(id,2)
        opval[#opval+1]=1
    end
    if b2 then
        ops[#ops+1]=aux.Stringid(id,3)
        opval[#opval+1]=2
    end
    local sel=opval[Duel.SelectOption(tp,table.unpack(ops))+1]
    e:SetLabel(sel)
    if sel==1 then
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
    else
        Duel.SetOperationInfo(0,CATEGORY_SSET,nil,1,tp,LOCATION_DECK)
    end
end

-- ① 操作
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local sel=e:GetLabel()
    if sel==1 then
        local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,e,tp)
        if #g==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
        local tc=g:Select(tp,1,1,nil):GetFirst()
        if not tc then return end
        local b1=tc:IsAbleToHand()
        local b2=tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
        local use_sp=false
        if b1 and b2 then
            use_sp = Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))==1
        elseif b2 then
            use_sp=true
        elseif not b1 then
            return
        end
        if use_sp then
            Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(e2)
            Duel.SpecialSummonComplete()
        else
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        end

        if not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,15040016) then
            local rel=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
            if #rel>0 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
                local rg=rel:Select(tp,1,1,nil)
                if #rg>0 then
                    Duel.Release(rg,REASON_EFFECT)
                end
            end
        end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #sg==0 then return end
        Duel.SSet(tp,sg:GetFirst())

        if not Duel.IsExistingMatchingCard(function(c) return c:IsCode(26062911) and c:IsFaceup() end,tp,LOCATION_ONFIELD,0,1,nil) then
            -- 修正：场上的魔法·陷阱位于 LOCATION_SZONE，而非 LOCATION_MZONE
            local rm=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,nil)
            if #rm>0 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
                local rg=rm:Select(tp,1,1,nil)
                if #rg>0 then
                    Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
                end
            end
        end
    end
end

-- ① 可解放的怪兽（手卡·场上怪兽）
function s.relfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsReleasable()
end
-- ① 可除外的魔法·陷阱（手卡·场上魔法与陷阱区域）
function s.rmfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end

-- ② 代替破坏的对象：自己场上的「千早爱音」怪兽
function s.repfilter(c,tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
        and c:IsSetCard(0xb12) and c:IsType(TYPE_MONSTER)
        and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and c:IsAbleToRemove() end
    return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
-- ② 操作：直接检查卡是否仍在墓地，然后除外
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove() then
        Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
    end
end