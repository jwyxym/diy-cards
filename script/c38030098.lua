--堕魂之夜 大谢幕
local m=38030098 --卡号待定
local cm=_G["c"..m]

function cm.initial_effect(c)
	--fusion summon
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,m)
	aux.AddFusionProcFunRep(c,cm.ffilter,3,true)   
	aux.AddContactFusionProcedure(c,cm.cfilter,LOCATION_ONFIELD+LOCATION_GRAVE,0,aux.tdcfop(c))
	--destroy all other monsters
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHANGE_POS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,m)
	e4:SetTarget(cm.destg)
	e4:SetOperation(cm.desop)
	c:RegisterEffect(e4)
	
	--cannot be destroyed by battle
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	
	--change position
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(m,1))
	e6:SetCategory(CATEGORY_POSITION)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BECOME_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,m+1)
	e6:SetCondition(cm.poscon)
	e6:SetOperation(cm.posop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e7)
--召唤词
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e9:SetCode(EVENT_SPSUMMON_SUCCESS)
	e9:SetCountLimit(1,38030098+10000)
	e9:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e9:SetOperation(c38030098.cop)
	c:RegisterEffect(e9)
	end
function c38030098.cop(e,tp,eg,ep,ev,re,r,rp)
	Debug.Message("少女们受诅咒的灵魂啊，交织描绘成讴歌悲剧的倒吊舞台！")
	Debug.Message("贡献出与自己希望同等的绝望，拉开破灭轮回的序幕吧！")
	Debug.Message("堕魂之夜 舞台设置")
end
function cm.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.matfilter(c,fc,sub,mg,sg)
		if not sg then return true end
	return not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()) and  c:IsFusionSetCard(0x615) 
end
--fusion filter
function cm.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x615) and c:IsLevelAbove(8) 
end

--special summon condition
function cm.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x615) and c:IsLevelAbove(8) 
		and c:IsAbleToDeck() and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_GRAVE))
end

function cm.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(cm.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)>=3 and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end

function cm.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(cm.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(sg,nil,2,REASON_COST)
end

--summon limit
function cm.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end

--destroy all
function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if chk==0 then return #g>0 end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end

function cm.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	Duel.Destroy(g,REASON_EFFECT)
end

--position change
function cm.poscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end

function cm.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
