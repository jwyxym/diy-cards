--冰晶魔女 露娜
local cm,m=GetID()

function cm.initial_effect(c)
	c:EnableCounterPermit(0x1)
    --
    aux.AddLinkProcedure(c,nil,3,6,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(cm.regcon)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
    --release
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.recost)
	e1:SetTarget(cm.retg)
	e1:SetOperation(cm.reop)
	c:RegisterEffect(e1)
end

function cm.lcheck(g)
	return g:IsExists(Card.IsLink,1,nil,2)
end

function cm.lcheck2(g)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_SPELLCASTER) and g:IsExists(Card.IsLinkType,1,nil,TYPE_PENDULUM)
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.tgtfilter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsLocation(0x70) and c:IsFaceup() and c:IsLinkAbove(1)
end

function cm.tgtfilterg(g,tp,tc)
    local l1=g:GetFirst():GetLink()
    local l2=g:GetFirst():GetNext():GetLink()
    return Duel.IsPlayerCanDraw(tp,math.min(l1,l2)) and tc:IsCanAddCounter(0x1,l1+l2)
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    local mg=c:GetMaterial():Filter(cm.tgtfilter,nil,e)
    if chkc then return false end
	if chk==0 then return mg:CheckSubGroup(cm.tgtfilterg,2,2,tp,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=mg:SelectSubGroup(tp,cm.tgtfilterg,false,2,2,tp,c)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,nil)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToChain)
    if c:IsRelateToChain() and c:IsFaceup() and #tg>0 then
        local lnum,dnum=0,99
        for tc in aux.Next(tg) do
            local l1=tc:GetLink()
            lnum=lnum+l1
            if dnum>l1 then
                dnum=l1
            end
        end
        if c:AddCounter(0x1,lnum) and dnum~=99 then
            Duel.Draw(tp,dnum,REASON_EFFECT)
        end
    end
end

function cm.costcfilter(c)
    return c:GetCounter(0x1)>0 and c:IsAbleToRemoveAsCost()
end

function cm.recost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.costcfilter,tp,0x0c,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,cm.costcfilter,tp,0x0c,0,1,1,nil):GetFirst()
    if tc then
        e:SetLabel(tc:GetCounter())
        Duel.Remove(tc,POS_FACEUP,REASON_COST)
    end
end

function cm.retg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetFieldGroup(tp,0,0x0c)
	if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,nil,nil)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel()*150)
end

function cm.reop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,0x0c,1,1,nil)
    if #g>0 then
        Duel.HintSelection(g)
        if Duel.Destroy(g,REASON_EFFECT) then
            local tc=g:GetFirst()
            if tc:GetFlagEffect(m)==0 then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_FIELD)
                e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
                e1:SetCode(EFFECT_CANNOT_ACTIVATE)
                e1:SetLabelObject(tc)
                e1:SetTargetRange(1,1)
                e1:SetValue(cm.aclimit)
                e1:SetReset(RESET_PHASE+PHASE_END)
                Duel.RegisterEffect(e1,tp)
                tc:RegisterFlagEffect(m,RESET_PHASE+PHASE_END,0,1,0,aux.Stringid(m,0))
            end
            Duel.BreakEffect()
            Duel.Recover(tp,e:GetLabel()*150,REASON_EFFECT)
        end
    end
end

function cm.aclimit(e,re,tp)
    return re:GetHandler()==e:GetLabelObject() and (re:IsHasType(0x280) or (re:IsHasType(0x510) and re:GetCode()~=EVENT_FREE_CHAIN))
end