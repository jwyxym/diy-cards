--大侦探-福尔摩斯 (45205324)
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
    
    --②效果：无效并除外
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id+100)
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end

function s.splimit(e,se,sp,st)
    return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
        or (se and se:GetHandler():IsSetCard(0x1D5C))
end

-- ★★★ 素材过滤：只检查字段+类型 ★★★
function s.matfilter(c)
    return c:IsSetCard(0x1D5C) and c:IsType(TYPE_MONSTER)
end

-- ★★★ 检查选中的2只是否分别来自场上和墓地 ★★★
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

-- ★★★ 接触融合条件 ★★★
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    if not s.magic_activated(tp) then return false end
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    return g:CheckSubGroup(s.fselect,2,2,tp,c)
end

-- ★★★ 用 SelectSubGroup 一次性选2只 ★★★
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

-- ★★★ 素材返回：场上→卡组，墓地→卡组/额外 ★★★
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

--①检索
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

--②效果
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp and Duel.IsChainDisablable(ev)
        and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local types={}
    local texts={}
    types[#types+1]=0
    texts[#texts+1]=aux.Stringid(id,2)
    types[#types+1]=1
    texts[#texts+1]=aux.Stringid(id,3)
    types[#types+1]=2
    texts[#texts+1]=aux.Stringid(id,4)
    local choice=Duel.SelectOption(tp,table.unpack(texts))
    e:SetLabel(types[choice+1])
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local typ=e:GetLabel()
    local p=1-tp
    
    if Duel.GetFieldGroupCount(p,LOCATION_DECK,0)<3 then return end
    
    local g=Duel.GetDecktopGroup(p,3)
    if #g<3 then return end
    
    Duel.ConfirmCards(tp,g)
    Duel.ConfirmCards(p,g)
    
    local has_type=false
    local tc=g:GetFirst()
    while tc do
        if (typ==0 and tc:IsType(TYPE_MONSTER)) or (typ==1 and tc:IsType(TYPE_SPELL)) or (typ==2 and tc:IsType(TYPE_TRAP)) then
            has_type=true
            break
        end
        tc=g:GetNext()
    end
    
    if has_type then
        if Duel.NegateEffect(ev) then
            local filter=aux.TRUE
            if typ==0 then
                filter=function(c) return c:IsType(TYPE_MONSTER) end
            elseif typ==1 then
                filter=function(c) return c:IsType(TYPE_SPELL) end
            elseif typ==2 then
                filter=function(c) return c:IsType(TYPE_TRAP) end
            end
            if Duel.IsExistingMatchingCard(filter,tp,0,LOCATION_ONFIELD,1,nil)
                and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
                local sg=Duel.SelectMatchingCard(tp,filter,tp,0,LOCATION_ONFIELD,1,1,nil)
                if #sg>0 then
                    Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
                end
            end
        end
    end
    
    Duel.ShuffleDeck(p)
end