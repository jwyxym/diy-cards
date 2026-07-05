--大侦探-福尔摩斯 (45205324)
--卡密ID: 45205324
--字段代码: 0x1D5C

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddFusionProcMix(c,true,true,
        aux.FilterBoolFunction(Card.IsSetCard,0x1D5C),
        aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER))
    
    --特殊召唤限制
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(s.splimit)
    c:RegisterEffect(e0)
    
    --接触融合手续
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    -- ★★★ 加1回合1次限制 ★★★
    e1:SetCountLimit(1,id+300)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    --①效果：特殊召唤时检索
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    
    --②效果：无效并除外（直接抄「最佳的侦探组合」）
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+200)
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end

function s.splimit(e,se,sp,st)
    return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
        or (se and se:GetHandler():IsSetCard(0x1D5C))
end

function s.matfilter(c)
    return c:IsSetCard(0x1D5C) and c:IsType(TYPE_MONSTER)
end

function s.fselect(g,tp,sc)
    if g:GetCount()~=2 then return false end
    local ct1=0
    local ct2=0
    local tc=g:GetFirst()
    while tc do
        if tc:IsLocation(LOCATION_MZONE) then ct1=ct1+1 end
        if tc:IsLocation(LOCATION_GRAVE) then ct2=ct2+1 end
        tc=g:GetNext()
    end
    return ct1==1 and ct2==1 and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end

function s.magic_activated(tp)
    local turn=Duel.GetTurnCount()
    local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0)
    local tc=g:GetFirst()
    while tc do
        if tc:IsSetCard(0x1D5C) and tc:IsType(TYPE_SPELL) and tc:GetTurnID()==turn then
            return true
        end
        tc=g:GetNext()
    end
    return false
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    if not s.magic_activated(tp) then return false end
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    return g:CheckSubGroup(s.fselect,2,2,tp,c)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=g:SelectSubGroup(tp,s.fselect,true,2,2,tp,c)
    if sg then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    end
    return false
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    if not sg then return end
    local tc=sg:GetFirst()
    while tc do
        if tc:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) then
            Duel.SendtoExtraP(tc,nil,REASON_EFFECT+REASON_MATERIAL)
        else
            Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL)
        end
        tc=sg:GetNext()
    end
    e:SetLabelObject(nil)
end

function s.thfilter(c)
    return (c:IsSetCard(0x1D5C) and c:IsType(TYPE_SPELL+TYPE_TRAP)) or c:IsCode(77027445)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

--②效果：无效并除外
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return ep~=tp and c:IsFaceup() and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
    
    local opt=Duel.AnnounceType(tp)
    
    if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<3 then return end
    Duel.ConfirmDecktop(1-tp,3)
    local g=Duel.GetDecktopGroup(1-tp,3)
    local has=false
    
    local tc=g:GetFirst()
    while tc do
        if (opt==0 and tc:IsType(TYPE_MONSTER)) or (opt==1 and tc:IsType(TYPE_SPELL)) or (opt==2 and tc:IsType(TYPE_TRAP)) then
            has=true
            break
        end
        tc=g:GetNext()
    end
    
    if has then
        Duel.NegateEffect(ev)
        
        local sg=Duel.GetMatchingGroup(Card.IsFaceup,1-tp,LOCATION_ONFIELD,0,nil)
        local tg=sg:Filter(Card.IsType,nil,opt==0 and TYPE_MONSTER or (opt==1 and TYPE_SPELL) or (opt==2 and TYPE_TRAP))
        if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local rg=tg:Select(tp,1,1,nil)
            if #rg>0 then
                Duel.Remove(rg:GetFirst(),POS_FACEUP,REASON_EFFECT)
            end
        end
    end
    
    Duel.ShuffleDeck(1-tp)
end