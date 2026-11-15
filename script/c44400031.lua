-- 雾都的侦探小姐 (ID: 44400031)
local s,id,o=GetID()
local SET_CRYSTAL_FLOWER=0x68f -- 「水晶花」字段
local SET_YE_CU=0x97f          -- 「业簇」字段
local CARD_DINATO_TUNA=44400046 -- 「狄娜托·图娜」

function s.initial_effect(c)
	-- 融合召唤手续：「狄娜托·图娜」＋「水晶花」怪兽或者魔法师族怪兽１只
	c:EnableReviveLimit()
	aux.AddCodeList(c,CARD_DINATO_TUNA)
	aux.AddSetNameMonsterList(c,SET_CRYSTAL_FLOWER,SET_YE_CU)
	aux.AddFusionProcMix(c,true,true,CARD_DINATO_TUNA,s.matfilter)

	-- 特殊召唤手续：自己场上１只有装备卡装备的「狄娜托·图娜」解放的场合才能从额外卡组特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)

	local e0b=Effect.CreateEffect(c)
	e0b:SetDescription(aux.Stringid(id,0))
	e0b:SetType(EFFECT_TYPE_FIELD)
	e0b:SetCode(EFFECT_SPSUMMON_PROC)
	e0b:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0b:SetRange(LOCATION_EXTRA)
	e0b:SetCondition(s.spcon0)
	e0b:SetTarget(s.sptg0)
	e0b:SetOperation(s.spop0)
	c:RegisterEffect(e0b)

	-- ①：这张卡特殊召唤成功的场合才能发动。选手卡·卡组·墓地各最多１张「业簇」装备卡给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.eqtg1)
	e1:SetOperation(s.eqop1)
	c:RegisterEffect(e1)

	-- ②：自己的主要阶段才能发动。这张卡装备的装备卡全部破坏，将最多有那个数量的「水晶花」怪兽从手卡·墓地·额外卡组效果无效特殊召唤。这个回合，自己不是记述有「狄娜托·图娜」的怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,5))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end

-- 融合素材过滤（「水晶花」怪兽或魔法师族怪兽）
function s.matfilter(c,fc,sub,mg,sg)
	return c:IsSetCard(SET_CRYSTAL_FLOWER) or c:IsRace(RACE_SPELLCASTER)
end

-- 特殊召唤限制（仅能融合召唤或自身接触手段特召）
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

--------------------------------------------------------------------------------
-- 接触特召判定（使用官方标准 Duel.CheckReleaseGroup / SelectReleaseGroup）
--------------------------------------------------------------------------------
function s.spfilter0(c,tp,sc)
	return c:IsFaceup() and c:IsCode(CARD_DINATO_TUNA) and c:GetEquipCount()>0
		and c:IsReleasable() and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end

function s.spcon0(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.spfilter0,1,nil,tp,c)
end

function s.sptg0(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.spfilter0,1,1,nil,tp,c)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end

function s.spop0(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end

--------------------------------------------------------------------------------
-- ①效果：特召成功手卡·卡组·墓地各最多1张装备「业簇」
--------------------------------------------------------------------------------
function s.eqfilter1(c,tc,tp)
	return c:IsSetCard(SET_YE_CU) and c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(tc)
end

function s.eqtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.eqfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.eqop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end

	local hg=Duel.GetMatchingGroup(s.eqfilter1,tp,LOCATION_HAND,0,nil,c,tp)
	local dg=Duel.GetMatchingGroup(s.eqfilter1,tp,LOCATION_DECK,0,nil,c,tp)
	local gg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqfilter1),tp,LOCATION_GRAVE,0,nil,c,tp)
	local eqg=Group.CreateGroup()

	-- 手卡各最多1张
	if #hg>0 and #eqg<ft and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local sg1=hg:Select(tp,1,1,nil)
		eqg:Merge(sg1)
	end
	-- 卡组各最多1张
	if #dg>0 and #eqg<ft and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local sg2=dg:Select(tp,1,1,nil)
		eqg:Merge(sg2)
	end
	-- 墓地各最多1张
	if #gg>0 and #eqg<ft and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local sg3=gg:Select(tp,1,1,nil)
		eqg:Merge(sg3)
	end

	if #eqg>0 then
		for tc in aux.Next(eqg) do
			Duel.Equip(tp,tc,c,true,true)
		end
		Duel.EquipComplete()
	end
end

--------------------------------------------------------------------------------
-- ②效果：炸全部装备卡，等量特召「水晶花」怪兽并加誓约限制
--------------------------------------------------------------------------------
function s.spfilter2(c,e,tp)
	return c:IsSetCard(SET_CRYSTAL_FLOWER) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spgoal(g,tp)
	local ex_ct=g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
	local main_ct=#g-ex_ct
	local ft_main=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft_ex=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)
	return main_ct<=ft_main and ex_ct<=ft_ex and #g<=ft_main+ft_ex
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local eqg=c:GetEquipGroup()
	if chk==0 then
		return eqg and #eqg>0 and eqg:IsExists(Card.IsDestructable,1,nil,e)
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eqg,#eqg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local eqg=c:GetEquipGroup()
	if not eqg or #eqg==0 then return end
	local ct=Duel.Destroy(eqg,REASON_EFFECT)
	if ct>0 then
		local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp)
		if #tg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=tg:SelectSubGroup(tp,s.spgoal,false,1,ct,tp)
			if sg and #sg>0 then
				Duel.BreakEffect()
				for tc in aux.Next(sg) do
					if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
						-- 效果无效
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_DISABLE)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e1)
						local e2=Effect.CreateEffect(c)
						e2:SetType(EFFECT_TYPE_SINGLE)
						e2:SetCode(EFFECT_DISABLE_EFFECT)
						e2:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e2)
					end
				end
				Duel.SpecialSummonComplete()
			end
		end
	end

	-- 这个回合，自己不是记述有「狄娜托·图娜」的怪兽不能从额外卡组特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,6))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit_turn)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
end

function s.is_listed_dina(c)
	local code=c:GetOriginalCode()
	local mt=_G["c"..code] or _G["s"..code]
	return c:IsCode(CARD_DINATO_TUNA)
		or aux.IsCodeListed(c,CARD_DINATO_TUNA)
		or (c.card_code_list and c.card_code_list[CARD_DINATO_TUNA])
		or (mt and mt.card_code_list and mt.card_code_list[CARD_DINATO_TUNA])
		or code==44400031 or code==44400038 or code==44400041
end

function s.splimit_turn(e,c,sump,sumtype,sumpos,target_p,se)
	return c:IsLocation(LOCATION_EXTRA) and not s.is_listed_dina(c)
end