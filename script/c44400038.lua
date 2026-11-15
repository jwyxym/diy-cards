-- 圣宣之络·狄娜托 (ID: 44400038)
local s,id,o=GetID()
local SET_CRYSTAL_FLOWER=0x68f -- 「水晶花」字段
local CARD_DINATO_TUNA=44400046 -- 「狄娜托·图娜」

function s.initial_effect(c)
	-- 同调召唤手续：调整＋「狄娜托·图娜」或者有那个卡名记述的怪兽1只
	c:EnableReviveLimit()
	aux.AddCodeList(c,CARD_DINATO_TUNA)
	aux.AddSetNameMonsterList(c,SET_CRYSTAL_FLOWER)
	aux.AddSynchroProcedure(c,nil,s.matfilter,1,1)

	-- ①：这张卡特殊召唤成功的场合才能发动。选对方场上１张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg1)
	e1:SetOperation(s.rmop1)
	c:RegisterEffect(e1)

	-- ②：对方把效果发动时才能发动。选卡组·墓地·除外状态的１张有记述「狄娜托·图娜」的魔法·陷阱卡给自己场上的怪兽装备。自己场上的怪兽的攻击力上升７００。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP+CATEGORY_ATKCHANGE+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetCondition(s.eqcon2)
	e2:SetTarget(s.eqtg2)
	e2:SetOperation(s.eqop2)
	c:RegisterEffect(e2)

	-- ③-1：自己场上·墓地有「水晶花」怪兽的场合，这张卡的卡名也当做「狄娜托·图娜」使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_ADD_CODE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.namecon)
	e3:SetValue(CARD_DINATO_TUNA)
	c:RegisterEffect(e3)

	-- ③-2：用同调调整为素材同调召唤的这张卡不受对方在场上发动的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.matcheck)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.immcon)
	e5:SetValue(s.immval)
	c:RegisterEffect(e5)
	e4:SetLabelObject(e5)
end

--------------------------------------------------------------------------------
-- 同调素材判定：记述了「狄娜托·图娜」的非调整怪兽
--------------------------------------------------------------------------------
function s.is_listed_dina(c)
	local code=c:GetOriginalCode()
	local mt=_G["c"..code] or _G["s"..code]
	return c:IsCode(CARD_DINATO_TUNA)
		or aux.IsCodeListed(c,CARD_DINATO_TUNA)
		or (c.card_code_list and c.card_code_list[CARD_DINATO_TUNA])
		or (mt and mt.card_code_list and mt.card_code_list[CARD_DINATO_TUNA])
		or code==44400031 or code==44400033 or code==44400034 or code==44400036 or code==44400038 or code==44400041
end

function s.matfilter(c,syncard)
	return c:IsNotTuner(syncard) and s.is_listed_dina(c)
end

--------------------------------------------------------------------------------
-- ①效果：特召成功选对方场上卡除外
--------------------------------------------------------------------------------
function s.rmtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.rmop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------
-- ②效果：响应对方发效，装备记述卡名魔陷并全员加攻（包含自身）
--------------------------------------------------------------------------------
function s.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end

function s.tgmonfilter(c,ec)
	return c:IsFaceup() and ec:CheckEquipTarget(c)
end

function s.eqfilter2(c,tp)
	if not (c:IsType(TYPE_SPELL|TYPE_TRAP) and s.is_listed_dina(c) and c:CheckUniqueOnField(tp)) then return false end
	if c:IsType(TYPE_EQUIP) then
		return Duel.IsExistingMatchingCard(s.tgmonfilter,tp,LOCATION_MZONE,0,1,nil,c)
	else
		return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
	end
end

function s.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.eqop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter2),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
		local ec=g:GetFirst()
		if ec then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local tg=nil
			if ec:IsType(TYPE_EQUIP) then
				tg=Duel.SelectMatchingCard(tp,s.tgmonfilter,tp,LOCATION_MZONE,0,1,1,nil,ec)
			else
				tg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
			end
			local tc=tg:GetFirst()
			if tc then
				if not ec:IsType(TYPE_EQUIP) then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetCode(EFFECT_EQUIP_LIMIT)
					e1:SetValue(s.eqlimit)
					e1:SetLabelObject(tc)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					ec:RegisterEffect(e1)
				end
				Duel.Equip(tp,ec,tc)
			end
		end
	end

	-- 自己场上的怪兽的攻击力上升７００（包含自身）
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if #mg>0 then
		Duel.BreakEffect()
		for mc in aux.Next(mg) do
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(700)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			mc:RegisterEffect(e2)
		end
	end
end

function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

--------------------------------------------------------------------------------
-- ③效果：水晶花在场·墓地时改名 ＋ 同调调整素材抗性
--------------------------------------------------------------------------------
function s.cffilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(SET_CRYSTAL_FLOWER) and c:IsType(TYPE_MONSTER)
end

function s.namecon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cffilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end

function s.matfilter_sync_tuner(c,sc)
	return c:IsType(TYPE_SYNCHRO,sc,SUMMON_TYPE_SYNCHRO) and c:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO)
end

function s.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.matfilter_sync_tuner,1,nil,c) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end

function s.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end

function s.immval(e,re)
	if re:GetOwnerPlayer()==e:GetHandlerPlayer() or not re:IsActivated() then return false end
	local loc=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION)
	return loc and loc&LOCATION_ONFIELD~=0
end