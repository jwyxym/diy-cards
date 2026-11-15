local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--从手卡的特殊召唤手续
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--① 对方不能解放自己场上的新星同盟怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetTarget(s.rellimit)
	c:RegisterEffect(e2)
	--② 解放四种原本卡名的怪兽获得胜利
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.wincon)
	e3:SetCost(s.wincost)
	e3:SetOperation(s.winop)
	c:RegisterEffect(e3)
end
function s.spfilter(c,tp)
	return c:IsFaceup() and c:IsCode(26052058) and c:IsAbleToGraveAsCost()
		and Duel.GetMZoneCount(tp,c)>0
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if not tc then return false end
	e:SetLabelObject(tc)
	return true
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.SendtoGrave(e:GetLabelObject(),REASON_SPSUMMON)
end
function s.rellimit(e,c,tp)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsLocation(LOCATION_MZONE)
		and c:IsSetCard(0x902)
end
function s.wincon(e,tp)
	return Duel.GetTurnPlayer()==tp
end
function s.winfilter(c)
	local code=c:GetOriginalCode()
	return (code==26052058 or code==26052059 or code==26051905 or code==26051956)
		and c:IsReleasable()
end
function s.wincheck(g)
	return g:GetClassCount(Card.GetOriginalCode)==4
end
function s.wincost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.winfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return g:CheckSubGroup(s.wincheck,4,4) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=g:SelectSubGroup(tp,s.wincheck,false,4,4)
	Duel.Release(sg,REASON_COST)
end
function s.winop(e,tp)
	Duel.Win(tp,0x915)
end
